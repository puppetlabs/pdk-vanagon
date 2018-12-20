component "puppet-forge-api" do |pkg, settings, platform|
  pkg.ref "master"
  pkg.url "git@github.com:puppetlabs/puppet-forge-api.git"

  pkg.build_requires "pdk-runtime"

  pkg.add_source('file://resources/files/windows/ruby_gem_wrapper.bat') if platform.is_windows?

  # We need a few different things that come from the Forge API codebase so we do it all in this component.

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

    settings[:additional_rubies]&.each do |rubyver, local_settings|
      gem_bins[local_settings[:ruby_api]] = local_settings[:host_gem]
      bundle_bins[local_settings[:ruby_api]] = local_settings[:host_bundle]
    end

    # TODO: build this dynamically somehow?
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
      '5.5.6'   => '2.4.0',
      '6.0.2'   => '2.5.0',
    }
    pdk_ruby_versions = puppet_rubyapi_versions.values.uniq

    puppet_gem_platform = platform.is_windows? ? 'x64-mingw32' : 'ruby'

    gem_install = lambda do |ruby_version, gem, version|
      [
        gem_bins[ruby_version],
        'install',
        '--clear-sources',
        "--source #{gem_source}",
        '--no-document',
        "--install-dir #{File.join(puppet_cachedir, ruby_version)}",
        "#{gem}:#{version}",
        "--platform #{puppet_gem_platform}",
      ].join(' ')
    end

    build_commands = []

    settings[:additional_rubies]&.each do |rubyver, local_settings|
      # Make backups of the gem and bundler wrapper batch files...
      build_commands << "cp #{gem_bins[local_settings[:ruby_api]]} #{gem_bins[local_settings[:ruby_api]]}.bak" if platform.is_windows?
      build_commands << "cp #{bundle_bins[local_settings[:ruby_api]]} #{bundle_bins[local_settings[:ruby_api]]}.bak" if platform.is_windows?

      # Update gem command on additional rubies to latest to avoid getting pre-release facter gems?
      rubygems_version = rubyver =~ /^2\.1/ ? "2.7.8" : "" # PDK-1247 Pin ruby 2.1.9 to latest compatible rubygems.
      build_commands << "#{gem_bins[local_settings[:ruby_api]]} update --system #{rubygems_version} --no-document"

      # ...replace the gem and bundler wrapper batch files file the backups we made.
      build_commands << "mv #{gem_bins[local_settings[:ruby_api]]}.bak #{gem_bins[local_settings[:ruby_api]]}" if platform.is_windows?
      build_commands << "mv #{bundle_bins[local_settings[:ruby_api]]}.bak #{bundle_bins[local_settings[:ruby_api]]}" if platform.is_windows?
    end

    build_commands += puppet_rubyapi_versions.collect do |pupver, rubyapi|
      gem_install.call(rubyapi, 'puppet', pupver)
    end

    find_in_cache_with_regex = '/usr/bin/find '
    find_in_cache_with_regex << '-E ' if platform.is_macos?
    find_in_cache_with_regex << puppet_cachedir << ' '
    find_in_cache_with_regex << '-regextype posix-extended ' unless platform.is_macos?
    find_in_cache_with_regex << '-regex '

    # The puppet gem has files in it's 'spec' directory with very long paths which
    # bump up against MAX_PATH on Windows. They also unncessarily bloat the package
    # size. Since the 'spec' directory is not required at runtime, we just purge it
    # before attempting to package.
    build_commands << "#{find_in_cache_with_regex} '.*/puppet-[[:digit:]]+\\.[[:digit:]]+\\.[[:digit:]]+[^/]*/spec/.*' -delete"

    # We also purge the included man pages.
    build_commands << "#{find_in_cache_with_regex} '.*/puppet-[[:digit:]]+\\.[[:digit:]]+\\.[[:digit:]]+[^/]*/man/.*' -delete"

    # We don't need the cached .gem packages either
    build_commands << "#{find_in_cache_with_regex} '.*/[[:digit:]]+\\.[[:digit:]]+\\.[[:digit:]]+/cache/.*\\.gem' -delete"

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
        # Byebug requires special treatment b/c the cross compiled into a fat gem
        byebug_libdir = File.join(puppet_cachedir, rubyapi, "gems", "byebug-9.0.6-x64-mingw32", "lib", "byebug")
        build_commands += [
          gem_install.call(rubyapi, 'byebug', '9.0.6'),
          "cp #{File.join(byebug_libdir, rubyapi.split('.')[0..1].join('.'), "byebug.so")} #{File.join(byebug_libdir, "byebug.so")}",
        ]

        # Add the remaining beaker dependencies that have been natively compiled
        # and repackaged.
        build_commands += beaker_native_deps.collect do |gem, ver|
          gem_install.call(rubyapi, gem, ver)
        end
      end
    end

    build_commands
  end

  # Cache the PE to puppet version mapping.
  pkg.install_file('lib/pe_versions.json', File.join(settings[:cachedir], 'pe_versions.json'))

  # Cache the task metadata schema.
  pkg.install_file('app/static/schemas/task.json', File.join(settings[:cachedir], 'task.json'))
end
