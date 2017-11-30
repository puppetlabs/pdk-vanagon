component "rubygem-addressable" do |pkg, settings, platform|
  pkg.version "2.5.2"
  pkg.md5sum "b469195cee7d4ebcd492cf7c514a5ad8"
  pkg.url "#{settings[:buildsources_url]}/addressable-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} addressable-#{pkg.get_version}.gem"
  end
end
