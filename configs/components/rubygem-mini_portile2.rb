component 'rubygem-mini_portile2' do |pkg, settings, platform|
  pkg.version settings[:mini_portile2_version]['default'][:version]
  pkg.md5sum settings[:mini_portile2_version]['default'][:checksum]
  pkg.url "#{settings[:buildsources_url]}/mini_portile2-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment 'PATH', settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} mini_portile2-#{pkg.get_version}.gem"
  end
end
