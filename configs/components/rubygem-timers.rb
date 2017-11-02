component "rubygem-timers" do |pkg, settings, platform|
  pkg.version "4.1.2"
  pkg.md5sum "2be9e4db59553d2aa6ae205c45e7a85b"
  pkg.url "#{settings[:buildsources_url]}/timers-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} timers-#{pkg.get_version}.gem"
  end
end
