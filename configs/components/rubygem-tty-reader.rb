component "rubygem-tty-reader" do |pkg, settings, platform|
  pkg.version "0.6.0"
  pkg.md5sum "a1ef4a718258db299322474940c7f59c"
  pkg.url "#{settings[:buildsources_url]}/tty-reader-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-reader-#{pkg.get_version}.gem"
  end
end
