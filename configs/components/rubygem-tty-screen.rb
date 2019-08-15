component "rubygem-tty-screen" do |pkg, settings, platform|
  pkg.version "0.7.0"
  pkg.md5sum "689532b1b9fca6ac07c007f8f1167e9f"
  pkg.url "#{settings[:buildsources_url]}/tty-screen-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-screen-#{pkg.get_version}.gem"
  end
end
