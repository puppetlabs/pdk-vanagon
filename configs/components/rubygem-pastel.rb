component "rubygem-pastel" do |pkg, settings, platform|
  pkg.version "0.7.3"
  pkg.md5sum "4227e7ba9c1b32a2ff9c26bb6ec96c0b"
  pkg.url "#{settings[:buildsources_url]}/pastel-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} pastel-#{pkg.get_version}.gem"
  end
end
