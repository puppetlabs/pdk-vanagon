component 'pdk-runtime' do |pkg, settings, platform|
  pkg.version settings[:pdk_runtime_version]
  pkg.sha1sum "http://builds.puppetlabs.lan/puppet-runtime/#{pkg.get_version}/artifacts/#{pkg.get_name}-#{pkg.get_version}.#{platform.name}.tar.gz.sha1"
  pkg.url "http://builds.puppetlabs.lan/puppet-runtime/#{pkg.get_version}/artifacts/#{pkg.get_name}-#{pkg.get_version}.#{platform.name}.tar.gz"
  pkg.install_only true

  install_commands = ["gunzip -c #{pkg.get_name}-#{pkg.get_version}.#{platform.name}.tar.gz | tar -C / -xf -"]

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]

    # We need to make sure we're setting permissions correctly for the executables
    # in the ruby bindir since preserving permissions in archives in windows is
    # ... weird, and we need to be able to use cygwin environment variable use
    # so cmd.exe was not working as expected.
    install_commands = [
      "gunzip -c #{pkg.get_name}-#{pkg.get_version}.#{platform.name}.tar.gz | tar -C /cygdrive/c/ -xf -",
      "chmod 755 #{settings[:ruby_bindir].sub(/C:/, '/cygdrive/c')}/*"
    ]

    settings[:additional_rubies].each do |rubyver, local_settings|
      install_commands << "chmod 755 #{local_settings[:ruby_bindir].sub(/C:/, '/cygdrive/c')}/*"
    end
  end

  # Clean up uneccesary files.
  install_commands << "rm -rf /opt/puppetlabs/pdk/bin/*"
  install_commands << "rm -rf /opt/puppetlabs/pdk/share/vim"
  install_commands << "rm -rf /opt/puppetlabs/pdk/share/aclocal"
  install_commands << "rm -rf /opt/puppetlabs/pdk/share/man"
  install_commands << "rm -rf /opt/puppetlabs/pdk/share/doc"
  install_commands << "rm -rf /opt/puppetlabs/pdk/share/augeas"
  install_commands << "rm -rf /opt/puppetlabs/pdk/ssl/misc"
  install_commands << "rm -rf /opt/puppetlabs/pdk/ssl/man"

  # TODO: investigate cygwin/rubygems shenanigans that prevent gem uninstall
  #       from working on windows.
  install_commands << "#{settings[:host_gem]} update --system"
  install_commands << "#{settings[:host_gem]} uninstall --all --executables rubygems-update"
  install_commands << "#{settings[:host_gem]} install --no-document bundler --version 1.16.1"
  settings[:additional_rubies].each do |rubyver, local_settings|
    rubygems_version = rubyver.start_with?('2.1') ? '2.7.10' : ''
    install_commands << "#{local_settings[:host_gem]} update --system #{rubygems_version}"
    install_commands << "#{local_settings[:host_gem]} uninstall --all --executables rubygems-update"
    install_commands << "#{local_settings[:host_gem]} install --no-document bundler --version 1.16.1"
  end

  pkg.install do
    install_commands
  end
end
