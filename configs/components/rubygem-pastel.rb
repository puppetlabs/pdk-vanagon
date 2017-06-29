component "rubygem-pastel" do |pkg, settings, platform|
  pkg.version "0.7.1"
  pkg.md5sum "d18811c988aff85c25823b9e78074685"
  pkg.url "http://buildsources.delivery.puppetlabs.net/pastel-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} pastel-#{pkg.get_version}.gem"
  end
end
