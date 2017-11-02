component "rubygem-tty-color" do |pkg, settings, platform|
  pkg.version "0.4.2"
  pkg.md5sum "5eeee7ff49775b8569bea975f77ea94d"
  pkg.url "#{settings[:buildsources_url]}/tty-color-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-color-#{pkg.get_version}.gem"
  end
end
