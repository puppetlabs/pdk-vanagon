component "rubygem-tty-prompt" do |pkg, settings, platform|
  pkg.version "0.12.0"
  pkg.md5sum "c9059b9c7b51ec49d7b8996e1de060c7"
  pkg.url "http://buildsources.delivery.puppetlabs.net/tty-prompt-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-prompt-#{pkg.get_version}.gem"
  end
end
