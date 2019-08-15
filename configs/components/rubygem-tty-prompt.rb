component "rubygem-tty-prompt" do |pkg, settings, platform|
  pkg.version "0.19.0"
  pkg.md5sum "0f8968795a476b6c5db2570ee4a177b0"
  pkg.url "#{settings[:buildsources_url]}/tty-prompt-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-prompt-#{pkg.get_version}.gem"
  end
end
