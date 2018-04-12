component "rubygem-cri" do |pkg, settings, platform|
  pkg.version "2.10.1"
  pkg.md5sum "3b270cde9529f1d738850b731c20f343"
  pkg.url "#{settings[:buildsources_url]}/cri-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} cri-#{pkg.get_version}.gem"
  end
end
