component "rubygem-pathspec" do |pkg, settings, platform|
  pkg.version "0.2.1"
  pkg.md5sum "7d7460f6ed1f832e13ca578ba0316d15"
  pkg.url "#{settings[:buildsources_url]}/pathspec-#{pkg.get_version}.gem"

  pkg.build_requires 'pdk-runtime'

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} pathspec-#{pkg.get_version}.gem"
  end
end
