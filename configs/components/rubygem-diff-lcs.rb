component "rubygem-diff-lcs" do |pkg, settings, platform|
  pkg.version "1.4.4"
  pkg.md5sum "62ee6015ca28466dbb8dd02655257a7c"
  pkg.url "#{settings[:buildsources_url]}/diff-lcs-#{pkg.get_version}.gem"

  pkg.build_requires 'pdk-runtime'

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} diff-lcs-#{pkg.get_version}.gem"
  end
end
