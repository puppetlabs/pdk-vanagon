component "rubygem-wisper" do |pkg, settings, platform|
  pkg.version "1.6.1"
  pkg.md5sum "cc98d091a08f410210fb577d15bd489c"
  pkg.url "http://buildsources.delivery.puppetlabs.net/wisper-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} wisper-#{pkg.get_version}.gem"
  end
end
