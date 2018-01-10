component "rubygem-equatable" do |pkg, settings, platform|
  pkg.version "0.5.0"
  pkg.md5sum "9ac7bbe951d558cec7e1d09313a1b79e"
  pkg.url "#{settings[:buildsources_url]}/equatable-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} equatable-#{pkg.get_version}.gem"
  end
end
