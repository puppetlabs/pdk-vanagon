component "rubygem-concurrent-ruby" do |pkg, settings, platform|
  pkg.version "1.1.5"
  pkg.md5sum "4409c2d6925d8448cb34a947eacaa29b"
  pkg.url "#{settings[:buildsources_url]}/concurrent-ruby-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} concurrent-ruby-#{pkg.get_version}.gem"
  end
end
