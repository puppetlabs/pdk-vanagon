component "rubygem-racc" do |pkg, settings, platform|
  pkg.version "1.6.2"
  pkg.sha256sum "58d26b3666382396fea84d33dc0639b7ee8d704156a52f8f22681f07b2f94f26"
  pkg.url "#{settings[:buildsources_url]}/racc-#{pkg.get_version}.gem"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} racc-#{pkg.get_version}.gem"
  end
end
