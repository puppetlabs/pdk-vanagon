component 'pdk-runtime' do |pkg, settings, platform|
  unless settings[:pdk_runtime_version] && settings[:pdk_runtime_location] && settings[:pdk_runtime_basename]
    raise "Expected to find :pdk_runtime_version, :pdk_runtime_location, and :pdk_runtime_basename settings; Please set these in your project file before including pdk-runtime as a component."
  end

  tarball_name = "#{settings[:pdk_runtime_basename]}.tar.gz"
  pkg.url File.join(settings[:pdk_runtime_location], tarball_name)
  pkg.sha1sum File.join(settings[:pdk_runtime_location], "#{tarball_name}.sha1")

  pkg.install_only true

  install_commands = ["gunzip -c #{tarball_name} | tar -C / -xf -"]

  if platform.is_windows?
    # We need to make sure we're setting permissions correctly for the executables
    # in the ruby bindir since preserving permissions in archives in windows is
    # ... weird, and we need to be able to use cygwin environment variable use
    # so cmd.exe was not working as expected.
    install_commands = [
      "gunzip -c #{tarball_name} | tar -C /cygdrive/c/ -xf -",
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
