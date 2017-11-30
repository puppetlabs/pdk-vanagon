component "rubygem-json_pure" do |pkg, settings, platform|
  pkg.version "2.1.0"
  pkg.md5sum "611938ea90a941ca220e1025262b0561"
  pkg.url "#{settings[:buildsources_url]}/json_pure-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} json_pure-#{pkg.get_version}.gem"
  end
end
