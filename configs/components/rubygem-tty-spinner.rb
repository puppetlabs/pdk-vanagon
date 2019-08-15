component "rubygem-tty-spinner" do |pkg, settings, platform|
  pkg.version "0.9.1"
  pkg.md5sum "ba5df1e9795700f6109a1a06cbecd355"
  pkg.url "#{settings[:buildsources_url]}/tty-spinner-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-spinner-#{pkg.get_version}.gem"
  end
end
