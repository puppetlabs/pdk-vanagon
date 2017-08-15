component "rubygem-tty-prompt" do |pkg, settings, platform|
  pkg.version "0.13.1"
  pkg.md5sum "033bca393ff6b7d67dd560cadf2be8c9"
  pkg.url "http://buildsources.delivery.puppetlabs.net/tty-prompt-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-prompt-#{pkg.get_version}.gem"
  end
end
