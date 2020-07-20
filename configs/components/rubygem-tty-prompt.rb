component "rubygem-tty-prompt" do |pkg, settings, platform|
  pkg.version "0.22.0"
  pkg.md5sum "7a98f5b7520238a9442e97643ffb564b"

  name = pkg.get_name.gsub('rubygem-', '')

  pkg.url("https://rubygems.org/downloads/#{name}-#{version}.gem")
  pkg.mirror("#{settings[:buildsources_url]}/#{name}-#{version}.gem")

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-prompt-#{pkg.get_version}.gem"
  end
end
