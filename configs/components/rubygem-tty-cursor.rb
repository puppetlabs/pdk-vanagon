component "rubygem-tty-cursor" do |pkg, settings, platform|
  pkg.version "0.5.0"
  pkg.md5sum "44bde28174e9e0f1a7987a3e3ab87aab"
  pkg.url "#{settings[:buildsources_url]}/tty-cursor-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-cursor-#{pkg.get_version}.gem"
  end
end
