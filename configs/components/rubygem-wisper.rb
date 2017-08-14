component "rubygem-wisper" do |pkg, settings, platform|
  pkg.version "2.0.0"
  pkg.md5sum "80deda8b4226106e88285373a8159f20"
  pkg.url "http://buildsources.delivery.puppetlabs.net/wisper-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} wisper-#{pkg.get_version}.gem"
  end
end
