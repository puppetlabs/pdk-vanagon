component "rubygem-deep_merge" do |pkg, settings, platform|
  pkg.version "1.2.1"
  pkg.md5sum "8d8396705375ac646454b1d64ad1239a"
  pkg.url "#{settings[:buildsources_url]}/deep_merge-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} deep_merge-#{pkg.get_version}.gem"
  end
end
