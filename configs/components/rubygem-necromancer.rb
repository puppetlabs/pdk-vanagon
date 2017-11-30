component "rubygem-necromancer" do |pkg, settings, platform|
  pkg.version "0.4.0"
  pkg.md5sum "f4e3986d55e53db3e8a47598e0e1db9c"
  pkg.url "#{settings[:buildsources_url]}/necromancer-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} necromancer-#{pkg.get_version}.gem"
  end
end
