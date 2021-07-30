component "rubygem-json_pure" do |pkg, settings, platform|
  pkg.version settings[:json_pure_component]['default'][:version]
  pkg.md5sum settings[:json_pure_component]['default'][:md5sum]
  pkg.url "#{settings[:buildsources_url]}/json_pure-#{pkg.get_version}.gem"
  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    [
      "#{settings[:gem_install]} json_pure-#{pkg.get_version}.gem",
    ]
  end
end
