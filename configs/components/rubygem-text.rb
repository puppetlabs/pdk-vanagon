component "rubygem-text" do |pkg, settings, platform|
  pkg.version "1.3.1"
  pkg.md5sum "514c3d1db7a955fe793fc0cb149c164f"
  pkg.url "#{settings[:buildsources_url]}/text-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} text-#{pkg.get_version}.gem"
  end
end
