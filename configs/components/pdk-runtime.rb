component 'pdk-runtime' do |pkg, settings, platform|
  if settings[:pdk_runtime_version].length > 9
    # git sha version
    git_sha = settings[:pdk_runtime_version]

    require 'open-uri'
    build_metadata = JSON.parse(open("http://builds.delivery.puppetlabs.net/puppet-runtime/#{git_sha}/artifacts/#{git_sha}.build_metadata.json").read)

    pkg.version build_metadata['version']
    runtime_path = git_sha
  else
    # date-based tag
    pkg.version settings[:pdk_runtime_version]
    runtime_path = pkg.get_version
  end

  pkg.sha1sum "http://builds.delivery.puppetlabs.net/puppet-runtime/#{runtime_path}/artifacts/#{pkg.get_name}-#{pkg.get_version}.#{platform.name}.tar.gz.sha1"
  pkg.url "http://builds.delivery.puppetlabs.net/puppet-runtime/#{runtime_path}/artifacts/#{pkg.get_name}-#{pkg.get_version}.#{platform.name}.tar.gz"

  pkg.install_only true

  install_commands = ["gunzip -c #{pkg.get_name}-#{pkg.get_version}.#{platform.name}.tar.gz | tar -C / -xf -"]

  if platform.is_windows?
    # We need to make sure we're setting permissions correctly for the executables
    # in the ruby bindir since preserving permissions in archives in windows is
    # ... weird, and we need to be able to use cygwin environment variable use
    # so cmd.exe was not working as expected.
    install_commands = [
      "gunzip -c #{pkg.get_name}-#{pkg.get_version}.#{platform.name}.tar.gz | tar -C /cygdrive/c/ -xf -",
      "chmod 755 #{settings[:ruby_bindir].sub(/C:/, '/cygdrive/c')}/*"
    ]

    settings[:additional_rubies].each do |_rubyver, local_settings|
      install_commands << "chmod 755 #{local_settings[:ruby_bindir].sub(/C:/, '/cygdrive/c')}/*"
    end
  end

  # Clean up uneccesary files.
  files = [
    'share/vim',
    'share/aclocal',
    'share/man',
    'share/doc',
    'share/augeas',
    'ssl/misc',
    'ssl/man'
  ]

  files << 'bin/*' unless platform.is_windows?

  bin_dir = platform.is_windows? ? settings[:prefix].sub(/C:/, '/cygdrive/c') : settings[:prefix]
  files.each do |file|
    install_commands << "rm -rf #{bin_dir}/#{file}"
  end

  pkg.install do
    install_commands
  end
end
