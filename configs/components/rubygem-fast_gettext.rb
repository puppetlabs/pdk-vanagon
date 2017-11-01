component "rubygem-fast_gettext" do |pkg, settings, platform|
  pkg.version "1.1.0"
  pkg.md5sum "fc0597bd4d84b749c579cc39c7ceda0f"
  pkg.url "#{settings[:buildsources_url]}/fast_gettext-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} fast_gettext-#{pkg.get_version}.gem"
  end
end
