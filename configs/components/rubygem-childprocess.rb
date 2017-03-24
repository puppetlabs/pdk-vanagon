component "rubygem-childprocess" do |pkg, settings, platform|
  pkg.version "0.6.2"
  pkg.md5sum "b0d728c5ead77c9488a42db50a62446b"
  pkg.url "http://buildsources.delivery.puppetlabs.net/childprocess-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-2.1.9"

  pkg.install do
    "#{settings[:gem_install]} childprocess-#{pkg.get_version}.gem"
  end
end
