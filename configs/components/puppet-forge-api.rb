component "puppet-forge-api" do |pkg, settings, platform|
  pkg.ref "master"
  pkg.url "git@github.com:puppetlabs/puppet-forge-api.git"

  pkg.build_requires "pdk-runtime"

  pkg.add_source('file://resources/files/windows/ruby_gem_wrapper.bat') if platform.is_windows?

  # We need a few different things that come from the Forge API codebase so we do it all in this component.

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.build do
    # Cache specific versions of the puppet gem
    gem_source = "https://artifactory.delivery.puppetlabs.net/artifactory/api/gems/rubygems"
    puppet_cachedir = File.join(settings[:privatedir], 'puppet', 'ruby')
    rubies_dir = File.join(settings[:privatedir], 'ruby')

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

    # TODO: build this dynamically from puppet_agent_compoents.json?
    puppet_rubyapi_versions = {
      '4.7.1'   => '2.1.0',
      '4.8.2'   => '2.1.0',
      '4.9.4'   => '2.1.0',
      '4.10.12' => '2.1.0',
      '5.0.1'   => '2.4.0',
      '5.1.0'   => '2.4.0',
      '5.2.0'   => '2.4.0',
      '5.3.7'   => '2.4.0',
      '5.4.0'   => '2.4.0',
      '5.5.21'  => '2.4.0',
      '6.0.10'  => '2.5.0',
      '6.1.0'   => '2.5.0',
      '6.2.0'   => '2.5.0',
      '6.3.0'   => '2.5.0',
      '6.4.5'   => '2.5.0',
      '6.5.0'   => '2.5.0',
      '6.6.0'   => '2.5.0',
      '6.7.2'   => '2.5.0',
      '6.8.1'   => '2.5.0',
      '6.9.0'   => '2.5.0',
      '6.10.1'  => '2.5.0',
      '6.11.1'  => '2.5.0',
      '6.12.0'  => '2.5.0',
      '6.13.0'  => '2.5.0',
      '6.14.0'  => '2.5.0',
      '6.15.0'  => '2.5.0',
      '6.16.0'  => '2.5.0',
      '6.17.0'  => '2.5.0',
    }
    pdk_ruby_versions = puppet_rubyapi_versions.values.uniq

    puppet_gem_platform = platform.is_windows? ? 'x64-mingw32' : 'ruby'

    gem_install = lambda do |ruby_version, gem, version, *args|
      [
        gem_bins[ruby_version],
        'install',
        '--clear-sources',
        "--source #{gem_source}",
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

      # PDK-1247: Pin ruby 2.1.9 to latest compatible rubygems.
      # PDK-1590: Pin ruby >= 2.4 to rubygems 3.0.0 due to path-with-spaces
      #   weirdness on Windows (also deprecation notice spam due to change
      #   introduced in 3.1.0).
      rubygems_version = ruby_version =~ /^2\.1\./ ? "2.7.9" : "3.0.0"
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
      gem_install.call(rubyapi, 'puppet', pupver)
    end

    if platform.is_windows?
      wrapper_path = File.join('..', 'ruby_gem_wrapper.bat')
      build_commands << "/usr/bin/find #{puppet_cachedir} -name '*.bat' -exec cp #{wrapper_path} {} \\;"
      build_commands << "/usr/bin/find #{rubies_dir} -type f -name '*.bat' -exec cp #{wrapper_path} {} \\;"

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
        build_commands += beaker_native_deps.collect do |gem, ver|
          gem_install.call(rubyapi, gem, ver)
        end

        build_commands << gem_install.call(rubyapi, 'rb-readline', '0.5.5')
      end
    end

    build_commands
  end

  # Cache the PE to puppet version mapping.
  pkg.install_file('lib/pe_versions.json', File.join(settings[:cachedir], 'pe_versions.json'))
end
