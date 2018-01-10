component "rubygem-diff-lcs" do |pkg, settings, platform|
  pkg.version "1.3"
  pkg.md5sum "9b1664d1bdf336f4309343c2a640d9e8"
  pkg.url "#{settings[:buildsources_url]}/diff-lcs-#{pkg.get_version}.gem"

  pkg.build_requires 'pdk-runtime'

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} diff-lcs-#{pkg.get_version}.gem"
  end
end
