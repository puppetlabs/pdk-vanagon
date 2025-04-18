component 'puppet-versions' do |pkg, settings, platform|
  # Install all the various versions of the puppet gem and dependencies that we
  # package with PDK.

  pkg.build_requires 'pdk-runtime'

  pkg.add_source('file://resources/puppet-versions')

  if platform.is_windows?
    pkg.environment 'PATH', settings[:gem_path_env]
  end

  # We use various Gem::* classes to test versions and ranges
  require 'rubygems'

  def latest_puppet_gem(req)
    require 'gems'

    @_puppet_all ||= Gems.versions 'puppet'
    @_puppet_in_range ||= {}

    @_puppet_in_range[req] ||= begin
      requirement = Gem::Requirement.create(req)

      @_puppet_all.collect do |v|
        pupver = Gem::Version.new(v['number'])
        next unless requirement.satisfied_by?(pupver)

        pupver
      end.compact.uniq.sort.max
    end
  end

  def ruby_for_puppet(version)
    # TODO: calculate this based on settings
    ruby_mappings = {
      '3.2.0' => Gem::Requirement.create(['~> 8.0'])
    }

    ruby_mappings.each do |rubyver, pup_range|
      return rubyver if pup_range.satisfied_by?(version)
    end

    raise "Could not determine Ruby API version for Puppet gem version: #{version}"
  end

  pkg.build do
    # Cache specific versions of the puppet gem
    puppet_cachedir = File.join(settings[:privatedir], 'puppet', 'ruby')

    gem_bins = {
      settings[:ruby_api] => settings[:host_gem]
    }

    bundle_bins = {
      settings[:ruby_api] => settings[:host_bundle]
    }

    ruby_dirs = {
      settings[:ruby_api] => settings[:ruby_dir]
    }

    settings[:additional_rubies]&.each do |_rubyver, local_settings|
      gem_bins[local_settings[:ruby_api]] = local_settings[:host_gem]
      bundle_bins[local_settings[:ruby_api]] = local_settings[:host_bundle]
      ruby_dirs[local_settings[:ruby_api]] = local_settings[:ruby_dir]
    end

    latest_puppet8 = latest_puppet_gem('~>8.0')
    # latest_puppet7 = latest_puppet_gem('~>7.0')

    latest_puppets = [latest_puppet8].compact
    puppet_rubyapi_versions = Hash[latest_puppets.collect { |pupver| [pupver.version, ruby_for_puppet(pupver)] }]
    pdk_ruby_versions = puppet_rubyapi_versions.values.uniq

    puppet_gem_platform = platform.is_windows? ? 'x64-mingw32' : 'ruby'

    gem_install = lambda do |ruby_version, gem, version, *args|
      [
        gem_bins[ruby_version],
        'install',
        '--verbose',
        '--clear-sources',
        '--no-document',
        "--install-dir #{File.join(puppet_cachedir, ruby_version)}",
        "#{gem}:#{version}",
        "--platform #{puppet_gem_platform}",
        *args
      ].join(' ')
    end

    rubygems_update = lambda do |_ruby_version, ruby_api|
      rubygems_update_commands = []

      # Make backups of the gem and bundler wrapper batch files...
      rubygems_update_commands << "cp #{gem_bins[ruby_api]} #{gem_bins[ruby_api]}.bak" if platform.is_windows?
      rubygems_update_commands << "cp #{bundle_bins[ruby_api]} #{bundle_bins[ruby_api]}.bak" if platform.is_windows?

      rubygems_version = '3.4.1'
      rubygems_update_commands << "#{gem_bins[ruby_api]} update --system #{rubygems_version} --no-document"

      # ...replace the gem and bundler wrapper batch files file the backups we made.
      rubygems_update_commands << "mv #{gem_bins[ruby_api]}.bak #{gem_bins[ruby_api]}" if platform.is_windows?
      rubygems_update_commands << "mv #{bundle_bins[ruby_api]}.bak #{bundle_bins[ruby_api]}" if platform.is_windows?

      rubygems_update_commands
    end

    build_commands = []

    # Update rubygems on "primary" Ruby
    build_commands += rubygems_update.call(settings[:ruby_version], settings[:ruby_api])

    # Update rubygems on "additional" rubies
    settings[:additional_rubies]&.each do |rubyver, local_settings|
      build_commands += rubygems_update.call(rubyver, local_settings[:ruby_api])
    end

    # Install "puppet" gem versions into appropriate Ruby installations.
    build_commands += puppet_rubyapi_versions.collect do |pupver, rubyapi|
      gem_install.call(rubyapi, 'puppet', pupver) if gem_bins[rubyapi]
    end

    if platform.is_windows?
      pdk_ruby_versions.each do |rubyapi|
        build_commands << gem_install.call(rubyapi, 'rb-readline', '0.5.5')
      end
    end

    build_commands
  end
end
