component "rubygem-equatable" do |pkg, settings, platform|
  pkg.version "0.6.1"
  pkg.md5sum "7881b33a583da680f63c88be3c6f1234"
  pkg.url "#{settings[:buildsources_url]}/equatable-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} equatable-#{pkg.get_version}.gem"
  end
end
