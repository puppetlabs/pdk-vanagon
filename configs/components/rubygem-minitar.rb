component "rubygem-minitar" do |pkg, settings, platform|
  pkg.version "0.6.1"
  pkg.md5sum "ce4ee63a94e80fb4e3e66b54b995beaa"
  pkg.url "#{settings[:buildsources_url]}/minitar-#{pkg.get_version}.gem"

  pkg.build_requires 'pdk-runtime'

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} minitar-#{pkg.get_version}.gem"
  end
end
