component 'rubygem-racc' do |pkg, settings, platform|
  pkg.version "1.5.0"
  pkg.md5sum "5a1239f6434da1353ca59594d9a88ee3"
  pkg.url "#{settings[:buildsources_url]}/racc-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment 'PATH', settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} racc-#{pkg.get_version}.gem"
  end
end
