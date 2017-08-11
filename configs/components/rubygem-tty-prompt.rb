component "rubygem-tty-prompt" do |pkg, settings, platform|
  pkg.version "0.13.0"
  pkg.md5sum "b44d04e0e1e9ec0e701d32949f828c6e"
  pkg.url "http://buildsources.delivery.puppetlabs.net/tty-prompt-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-prompt-#{pkg.get_version}.gem"
  end
end
