component "rubygem-json-schema" do |pkg, settings, platform|
  pkg.version "2.8.0"
  pkg.md5sum "075b4034f57ee8ab900a92a8da45054a"
  pkg.url "#{settings[:buildsources_url]}/json-schema-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} json-schema-#{pkg.get_version}.gem"
  end
end
