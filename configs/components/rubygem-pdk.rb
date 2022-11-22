component "rubygem-pdk" do |pkg, settings, platform|
  # Set url and ref from json files.
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

  pkg.build do
    wrapper = platform.is_windows? ? File.join('..', 'pdk.bat') : File.join('..', 'pdk_env_wrapper')
    [ "sed -i -e 's/@@@RUBY_VERSION@@@/#{settings[:ruby_version]}/' #{wrapper}" ]
  end

  if platform.is_windows?
    pkg.add_source("file://resources/files/windows/bin/pdk.bat", sum: "c34b343753ca2d159afd49856085fd2")
    pkg.install_file "../pdk.bat", "#{settings[:bindir]}/pdk.bat"
  else
    pkg.add_source("file://resources/files/posix/pdk_env_wrapper", sum: "bb9406aff5dd85731634386157cfd117")
    pkg.install_file "../pdk_env_wrapper", "#{settings[:link_bindir]}/pdk", mode: "0755"
  end
end
