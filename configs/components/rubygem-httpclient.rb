component "rubygem-httpclient" do |pkg, settings, platform|
  pkg.version "2.8.3"
  pkg.md5sum "0d43c4680b56547b942caa0d9fefa8ec"
  pkg.url "#{settings[:buildsources_url]}/httpclient-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} httpclient-#{pkg.get_version}.gem"
  end
end
