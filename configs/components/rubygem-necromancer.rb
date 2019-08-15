component "rubygem-necromancer" do |pkg, settings, platform|
  pkg.version "0.5.0"
  pkg.md5sum "9097316dbbe977e8b1aa449a9ae05890"
  pkg.url "#{settings[:buildsources_url]}/necromancer-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} necromancer-#{pkg.get_version}.gem"
  end
end
