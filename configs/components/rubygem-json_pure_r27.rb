component "rubygem-json_pure_r27" do |pkg, settings, platform|
  pkg.version settings[:json_pure_component]['2.7.0'][:version]
  pkg.md5sum settings[:json_pure_component]['2.7.0'][:md5sum]
  pkg.url "#{settings[:buildsources_url]}/json_pure-#{pkg.get_version}.gem"
  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:additional_rubies]['2.7.6'][:gem_install]} json_pure-#{pkg.get_version}.gem"
  end
end
