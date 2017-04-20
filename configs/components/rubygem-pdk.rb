component "rubygem-pdk" do |pkg, settings, platform|
	# Set url and ref from json file.
  pkg.load_from_json('configs/components/rubygem-pdk.json')
  pkg.version "0.1.0"

  pkg.build_requires "ruby-2.1.9"

  if platform.is_windows?
    pkg.environment "PATH", [
      "$(shell cygpath -u #{settings[:gcc_bindir]})",
      "$(shell cygpath -u #{settings[:ruby_bindir]})",
      "$(shell cygpath -u #{settings[:bindir]})",
      "/cygdrive/c/Windows/system32",
      "/cygdrive/c/Windows",
      "/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0",
    ].join(':')
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
    pkg.add_source("file://resources/files/windows/pdk.bat", sum: "f4364047a4d851650adb350b03aafd4b")

    pkg.install_file "../environment.bat", "#{settings[:main_bin]}/environment.bat"
    pkg.install_file "../pdk_shell.bat", "#{settings[:main_bin]}/pdk_shell.bat"
    pkg.install_file "../pdk.bat", "#{settings[:main_bin]}/pdk.bat"
  else
    pkg.link "#{settings[:bindir]}/pdk", "#{settings[:link_bindir]}/pdk"
  end
end
