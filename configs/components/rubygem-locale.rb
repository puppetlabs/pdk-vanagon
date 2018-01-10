component "rubygem-locale" do |pkg, settings, platform|
  pkg.version "2.1.2"
  pkg.md5sum "def1e89d1d3126a0c684d3b7b20d88d4"
  pkg.url "#{settings[:buildsources_url]}/locale-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} locale-#{pkg.get_version}.gem"
  end
end
