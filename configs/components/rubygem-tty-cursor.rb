component "rubygem-tty-cursor" do |pkg, settings, platform|
  pkg.version "0.4.0"
  pkg.md5sum "cbf8f9fee34919deccdc9656b2d131aa"
  pkg.url "http://buildsources.delivery.puppetlabs.net/tty-cursor-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-cursor-#{pkg.get_version}.gem"
  end
end
