component "rubygem-gettext-setup" do |pkg, settings, platform|
  pkg.version "0.24"
  pkg.md5sum "f766a5e12bbad9f85905638c500e08f6"
  pkg.url "#{settings[:buildsources_url]}/gettext-setup-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} gettext-setup-#{pkg.get_version}.gem"
  end
end
