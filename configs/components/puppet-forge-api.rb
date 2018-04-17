component "puppet-forge-api" do |pkg, settings, platform|
  pkg.ref "master"
  pkg.url "git@github.com:puppetlabs/puppet-forge-api.git"

  pkg.build_requires "pdk-runtime"

  # We need a few different things that come from the Forge API codebase so we do it all in this component.

  pkg.build do
    # Cache specific versions of the puppet gem
    gem_source = "https://artifactory.delivery.puppetlabs.net/artifactory/api/gems/rubygems"
    puppet_cachedir = File.join(settings[:privatedir], 'puppet', 'ruby')

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

    puppet_rubyapi_versions = {
      '4.7.1' => '2.1.0',
      '4.8.2' => '2.1.0',
      '4.9.4' => '2.1.0',
      '4.10.10' => '2.1.0',
      '5.0.1' => '2.4.0',
      '5.1.0' => '2.4.0',
      '5.2.0' => '2.4.0',
      '5.3.5' => '2.4.0',
      '5.4.0' => '2.4.0',
      '5.5.0' => '2.4.0',
    }

    build_commands = []

    # Update gem command on ruby 2.1.9 to latest to avoid getting pre-release facter gems?
    build_commands << "#{gem_bins['2.1.0']} update --system --no-document"

    # Replace the gem and bundler wrapper batch files...
    build_commands << "cp #{gem_bins['2.4.0']} #{gem_bins['2.1.0']}" if platform.is_windows?
    build_commands << "cp #{bundle_bins['2.4.0']} #{bundle_bins['2.1.0']}" if platform.is_windows?

    build_commands += puppet_rubyapi_versions.collect do |pupver, rubyapi|
      "#{gem_bins[rubyapi]} install --clear-sources --source #{gem_source} --no-document --install-dir #{File.join(puppet_cachedir, rubyapi)} puppet:#{pupver} --platform ruby"
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

    build_commands
  end

  # Cache the PE to puppet version mapping.
  pkg.install_file('lib/pe_versions.json', File.join(settings[:cachedir], 'pe_versions.json'))

  # Cache the task metadata schema.
  pkg.install_file('app/static/schemas/task.json', File.join(settings[:cachedir], 'task.json'))
end
