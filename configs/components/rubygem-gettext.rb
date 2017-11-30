component "rubygem-gettext" do |pkg, settings, platform|
  pkg.version "3.2.2"
  pkg.md5sum "4cbb125f8d8206e9a8f3a90f6488e4da"
  pkg.url "#{settings[:buildsources_url]}/gettext-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} gettext-#{pkg.get_version}.gem"
  end
end
