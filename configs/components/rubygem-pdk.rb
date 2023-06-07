component 'rubygem-pdk' do |pkg, settings, platform|
  # Set url and ref from json files.
  pkg.load_from_json('configs/components/rubygem-pdk.json')

  pkg.build_requires 'pdk-runtime'

  pkg.environment 'PATH', settings[:gem_path_env] if platform.is_windows?

  pkg.install do
    [
      "#{settings[:host_gem]} build pdk.gemspec",
      "#{settings[:gem_install]} pdk-#{pkg.get_version.tr('-', '.')}*.gem"
    ]
  end

  pkg.build do
    wrapper = platform.is_windows? ? File.join('..', 'pdk.bat') : File.join('..', 'pdk_env_wrapper')
    build_commands = [ "sed -i -e 's/@@@RUBY_VERSION@@@/#{settings[:ruby_version]}/' #{wrapper}" ]

    build_commands
  end

  if platform.is_windows?
    pkg.add_source('file://resources/files/windows/pdk.bat', sum: 'fbd50f4933d9e9db5d42725887247f4d')
    pkg.install_file '../pdk.bat', "#{settings[:bindir]}/pdk.bat"
  else
    pkg.add_source('file://resources/files/posix/pdk_env_wrapper', sum: 'bb9406aff5dd85731634386157cfd117')
    pkg.install_file '../pdk_env_wrapper', "#{settings[:link_bindir]}/pdk", mode: '0755'
  end
end
