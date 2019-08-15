component "rubygem-tty-cursor" do |pkg, settings, platform|
  pkg.version "0.7.0"
  pkg.md5sum "329a0638a3482041473461c49874bda3"
  pkg.url "#{settings[:buildsources_url]}/tty-cursor-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-cursor-#{pkg.get_version}.gem"
  end
end
