component "rubygem-tty-spinner" do |pkg, settings, platform|
  pkg.version "0.4.1"
  pkg.md5sum "cbcb1e9784183e0501cb1f5fc05829f1"
  pkg.url "http://buildsources.delivery.puppetlabs.net/tty-spinner-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-spinner-#{pkg.get_version}.gem"
  end
end
