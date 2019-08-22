component 'rubygem-mini_portile2-for-ruby-2.1.0' do |pkg, settings, platform|
  pkg.version settings[:mini_portile2_version]['2.1.0'][:version]
  pkg.md5sum settings[:mini_portile2_version]['2.1.0'][:checksum]
  pkg.url "#{settings[:buildsources_url]}/mini_portile2-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment 'PATH', settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} mini_portile2-#{pkg.get_version}.gem"
  end
end
