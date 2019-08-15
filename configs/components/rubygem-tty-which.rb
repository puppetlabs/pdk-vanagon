component "rubygem-tty-which" do |pkg, settings, platform|
  pkg.version "0.4.1"
  pkg.md5sum "f4afca72a52f8f64601cf6a41593eaad"
  pkg.url "#{settings[:buildsources_url]}/tty-which-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-which-#{pkg.get_version}.gem"
  end
end
