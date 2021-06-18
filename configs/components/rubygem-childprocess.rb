component "rubygem-childprocess" do |pkg, settings, platform|
  pkg.version "4.0.0"
  pkg.md5sum "3844066934646c3a6c80f1e46bb29b62"
  pkg.url "#{settings[:buildsources_url]}/childprocess-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} childprocess-#{pkg.get_version}.gem"
  end
end
