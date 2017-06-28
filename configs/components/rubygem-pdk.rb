component "rubygem-pdk" do |pkg, settings, platform|
	# Set url and ref from json file.
  pkg.load_from_json('configs/components/rubygem-pdk.json')
  pkg.version "0.2.0"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    [
      "#{settings[:host_gem]} build pdk.gemspec",
      "#{settings[:gem_install]} pdk-#{pkg.get_version}.gem",
    ]
  end

  if platform.is_windows?
    pkg.add_source("file://resources/files/windows/environment.bat", sum: "e7453da7fc1e5ad98125d099d4e11fa4")
    pkg.add_source("file://resources/files/windows/pdk_shell.bat", sum: "051a4c252e5239b9bc49a47bc92e21d9")
    pkg.add_source("file://resources/files/windows/pdk_shell.ps1", sum: "da73feba1043e2de87475f8eb02027c9")
    pkg.add_source("file://resources/files/windows/pdk.bat", sum: "f4364047a4d851650adb350b03aafd4b")

    pkg.install_file "../environment.bat", "#{settings[:main_bin]}/environment.bat"
    pkg.install_file "../pdk_shell.bat", "#{settings[:main_bin]}/pdk_shell.bat"
    pkg.install_file "../pdk_shell.ps1", "#{settings[:main_bin]}/pdk_shell.ps1"
    pkg.install_file "../pdk.bat", "#{settings[:main_bin]}/pdk.bat"
  else
    pkg.link "#{settings[:ruby_bindir]}/pdk", "#{settings[:link_bindir]}/pdk"
  end
end
