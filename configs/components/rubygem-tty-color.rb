component "rubygem-tty-color" do |pkg, settings, platform|
  pkg.version "0.5.0"
  pkg.md5sum "b6934266a52505e41cb1860bd11ee0c8"
  pkg.url "#{settings[:buildsources_url]}/tty-color-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-color-#{pkg.get_version}.gem"
  end
end
