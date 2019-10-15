component "rubygem-pdk" do |pkg, settings, platform|
	# Set url and ref from json file.
  pkg.load_from_json('configs/components/rubygem-pdk.json')

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    [
      "#{settings[:host_gem]} build pdk.gemspec",
      "#{settings[:gem_install]} pdk-#{pkg.get_version.tr('-', '.')}*.gem",
    ]
  end

  # Replace the @@@RUBY_VERSION@@@ placeholder in the wrapper script or
  # powershell module with the Ruby version specified in the pdk-runtime
  # settings.
  pkg.build do
    wrapper = if platform.is_windows?
                File.join('..', 'PuppetDevelopmentKit.psm1')
              else
                File.join('..', 'pdk_env_wrapper')
              end

    build_commands = [
      "sed -i -e 's/@@@RUBY_VERSION@@@/#{settings[:ruby_version]}/' #{wrapper}",
    ]

    if platform.windows?
      psd_file = File.join('..', 'PuppetDevelopmentKit.psd1')

      build_commands << "sed -i -e 's/@@@YEAR@@@/#{Time.now.utc.year}/' #{psd_file}"
    end

    build_commands
  end

  if platform.is_windows?
    # PowerShell Module
    pkg.add_source("file://resources/files/windows/PuppetDevelopmentKit/PuppetDevelopmentKit.psd1", sum: "ec3c0df4948b9c7c11ff665546e2e0ec")
    pkg.add_source("file://resources/files/windows/PuppetDevelopmentKit/PuppetDevelopmentKit.psm1", sum: "4a3270ba98de1c912ab733befed3c43c")

    pkg.directory "#{settings[:datadir]}/PowerShell/Modules/PuppetDevelopmentKit"
    pkg.install_file "../PuppetDevelopmentKit.psd1", "#{settings[:datadir]}/PowerShell/Modules/PuppetDevelopmentKit/PuppetDevelopmentKit.psd1"
    pkg.install_file "../PuppetDevelopmentKit.psm1", "#{settings[:datadir]}/PowerShell/Modules/PuppetDevelopmentKit/PuppetDevelopmentKit.psm1"
  else
    pkg.add_source("file://resources/files/posix/pdk_env_wrapper", sum: "bb9406aff5dd85731634386157cfd117")
    pkg.install_file "../pdk_env_wrapper", "#{settings[:link_bindir]}/pdk", mode: "0755"
  end
end
