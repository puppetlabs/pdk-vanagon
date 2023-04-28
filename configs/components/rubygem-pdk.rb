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
    wrapper = platform.is_windows? ? File.join('..', 'PuppetDevelopmentKit.psm1') : File.join('..', 'pdk_env_wrapper')
    build_commands = [ "sed -i -e 's/@@@RUBY_VERSION@@@/#{settings[:ruby_version]}/' #{wrapper}" ]

    if platform.is_windows?
      psd_file = File.join('..', 'PuppetDevelopmentKit.psd1')

      # Replace the @@@YEAR@@@ and @@@PDK_VERSION@@@ placeholders in the PSData
      # with the current year and PDK version.
      build_commands += [
        "sed -i -e 's/@@@YEAR@@@/#{Time.now.utc.year}/' #{psd_file}",
        "sed -i -e 's/@@@PDK_VERSION@@@/#{Gem::Version.new(pkg.get_version).release}/' #{psd_file}"
      ]
    end

    build_commands
  end

  if platform.is_windows?
    # pkg.add_source('file://resources/files/windows/pdk.bat', sum: 'c34b343753ca2d159afd49856085fd2')
    # pkg.install_file '../pdk.bat', "#{settings[:bindir]}/pdk.bat"

    pkg.add_source('file://resources/files/windows/PuppetDevelopmentKit/PuppetDevelopmentKit.psd1', sum: 'ec3c0df4948b9c7c11ff665546e2e0ec')
    pkg.add_source('file://resources/files/windows/PuppetDevelopmentKit/PuppetDevelopmentKit.psm1', sum: '4a3270ba98de1c912ab733befed3c43c')

    pkg.directory "#{settings[:datadir]}/PowerShell/Modules/PuppetDevelopmentKit"
    pkg.install_file '../PuppetDevelopmentKit.psd1', "#{settings[:datadir]}/PowerShell/Modules/PuppetDevelopmentKit/PuppetDevelopmentKit.psd1"
    pkg.install_file '../PuppetDevelopmentKit.psm1', "#{settings[:datadir]}/PowerShell/Modules/PuppetDevelopmentKit/PuppetDevelopmentKit.psm1"
  else
    pkg.add_source('file://resources/files/posix/pdk_env_wrapper', sum: 'bb9406aff5dd85731634386157cfd117')
    pkg.install_file '../pdk_env_wrapper', "#{settings[:link_bindir]}/pdk", mode: '0755'
  end
end
