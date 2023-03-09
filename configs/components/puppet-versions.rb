component 'puppet-versions' do |pkg, settings, platform|
  # Install all the various versions of the puppet gem and dependencies that we
  # package with PDK.

  pkg.build_requires 'pdk-runtime'

  pkg.add_source('file://resources/puppet-versions')

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  # We use various Gem::* classes to test versions and ranges
  require 'rubygems'

  # Return all available puppet gem versions (from rubygems.org) matching a range
  def available_puppet_gem_versions(range)
    require 'gems'

    @_puppet_all ||= Gems.versions 'puppet'
    @_puppet_in_range ||= {}

    @_puppet_in_range[range] ||= begin
      requirement = Gem::Requirement.create(range.split(' '))

      @_puppet_all.collect do |v|
        pupver = Gem::Version.new(v['number'])
        next unless requirement.satisfied_by?(pupver)
        pupver
      end.compact.uniq.sort
    end
  end

  # Filter a list of gem versions to only the latest .Z release of each .Y release
  def latest_z_releases(versions)
    latest = {}

    versions.each do |ver|
      major, minor, _ = ver.segments

      latest[major] ||= {}
      latest[major][minor] ||= nil

      next unless latest[major][minor].nil? || ver > latest[major][minor]

      latest[major][minor] = ver
    end

    latest.values.collect { |major| major.values }.flatten
  end

  def ruby_for_puppet(version)
    # TODO: calculate this based on settings
    ruby_mappings = {
      '2.5.0' => Gem::Requirement.create(['>= 6.0.0', '< 7.0.0']),
      '2.7.0' => Gem::Requirement.create(['>= 7.0.0', '< 8.0.0']),
    }

    ruby_mappings.each do |rubyver, pup_range|
      return rubyver if pup_range.satisfied_by?(version)
    end

    raise "Could not determine Ruby API version for Puppet gem version: #{version.to_s}"
  end

  pkg.build do
    # Cache specific versions of the puppet gem
    puppet_cachedir = File.join(settings[:privatedir], 'puppet', 'ruby')

    gem_bins = {
      settings[:ruby_api] => settings[:host_gem],
    }

    bundle_bins = {
      settings[:ruby_api] => settings[:host_bundle],
    }

    ruby_dirs = {
      settings[:ruby_api] => settings[:ruby_dir],
    }

    settings[:additional_rubies]&.each do |rubyver, local_settings|
      gem_bins[local_settings[:ruby_api]] = local_settings[:host_gem]
      bundle_bins[local_settings[:ruby_api]] = local_settings[:host_bundle]
      ruby_dirs[local_settings[:ruby_api]] = local_settings[:ruby_dir]
    end

    recent_puppets = available_puppet_gem_versions('>=6.24.0 <8.0.0')
    latest_puppets = latest_z_releases(recent_puppets)
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
        *args,
      ].join(' ')
    end

    rubygems_update = lambda do |ruby_version, ruby_api|
      rubygems_update_commands = []

      # Make backups of the gem and bundler wrapper batch files...
      rubygems_update_commands << "cp #{gem_bins[ruby_api]} #{gem_bins[ruby_api]}.bak" if platform.is_windows?
      rubygems_update_commands << "cp #{bundle_bins[ruby_api]} #{bundle_bins[ruby_api]}.bak" if platform.is_windows?

      rubygems_version = "3.2.3"
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
      # Add beaker dependencies
      beaker_native_deps = {
        'oga':     '2.15',
        'ruby-ll': '2.1.2',
      }

      pdk_ruby_versions.each do |rubyapi|
        settings[:byebug_version][rubyapi].each do |byebug_version|
          build_commands << gem_install.call(
            rubyapi,
            'byebug',
            byebug_version,
            '--',
            "--with-ruby-include=#{File.join(ruby_dirs[rubyapi], 'include', "ruby-#{rubyapi}")}",
            "--with-ruby-lib=#{File.join(ruby_dirs[rubyapi], 'lib')}",
          )

          # Byebug 9.x requires special treatment b/c the cross compiled into a fat gem
          if byebug_version.start_with?('9.')
            byebug_libdir = File.join(puppet_cachedir, rubyapi, "gems", "byebug-#{byebug_version}-x64-mingw32", "lib", "byebug")
            build_commands << "cp #{File.join(byebug_libdir, rubyapi.split('.')[0..1].join('.'), "byebug.so")} #{File.join(byebug_libdir, "byebug.so")}"
          end
        end

        # Add the remaining beaker dependencies that have been natively compiled
        # and repackaged.
        unless rubyapi =~ /^2\.7/
          build_commands += beaker_native_deps.collect do |gem, ver|
            gem_install.call(rubyapi, gem, ver)
          end
        end

        build_commands << gem_install.call(rubyapi, 'rb-readline', '0.5.5')
      end
    end

    # Download the PE version mapping file from the Forge API and save it into this
    # component's working directory. Later, during the install step, this will be
    # copied into the PDK cachedir.
    build_commands << "curl https://forgeapi.puppet.com/private/versions/pe > pe_versions.json"

    build_commands
  end

  # Cache the PE to puppet version mapping.
  pkg.install_file('pe_versions.json', File.join(settings[:cachedir], 'pe_versions.json'))
end

