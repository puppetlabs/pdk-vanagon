component "rubygem-racc" do |pkg, settings, platform|
  pkg.version "1.4.16"
  pkg.sha256sum "60e0533d33dd087cde78b613856321ec9c80c17962eaf4bfe62d22a6ca4c8bfa"
  pkg.url "#{settings[:buildsources_url]}/racc-#{pkg.get_version}.gem"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} racc-#{pkg.get_version}.gem"
  end
end
