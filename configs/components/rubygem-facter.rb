component "rubygem-facter" do |pkg, settings, platform|
  pkg.version "2.5.1"
  pkg.md5sum "5da7598481d6eb779a3fe770f73e24ee"
  pkg.url "#{settings[:buildsources_url]}/facter-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} facter-#{pkg.get_version}.gem"
  end
end
