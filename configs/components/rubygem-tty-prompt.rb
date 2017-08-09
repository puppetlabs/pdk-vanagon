component "rubygem-tty-prompt" do |pkg, settings, platform|
  pkg.version "0.13.0"
  pkg.md5sum "2c943c86bd6c6aa7dc67d0fc69d7ee6f"
  pkg.url "http://buildsources.delivery.puppetlabs.net/austb-tty-prompt-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-prompt-#{pkg.get_version}.gem"
  end
end
