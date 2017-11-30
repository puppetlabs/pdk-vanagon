component "rubygem-tty-spinner" do |pkg, settings, platform|
  pkg.version "0.5.0"
  pkg.md5sum "36cad9c558a576415e58d316621422c6"
  pkg.url "#{settings[:buildsources_url]}/tty-spinner-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-spinner-#{pkg.get_version}.gem"
  end
end
