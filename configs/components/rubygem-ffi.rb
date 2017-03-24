component "rubygem-ffi" do |pkg, settings, platform|
  gemname = pkg.get_name.gsub('rubygem-', '')
  pkg.version "1.9.18"
  pkg.md5sum "37284a51e5464443f7122b388329a2a0"
  pkg.url "http://buildsources.delivery.puppetlabs.net/#{gemname}-#{pkg.get_version}.gem"

  pkg.build_requires "cmake"

  if platform.is_rpm?
    # red hat
    pkg.build_requires "pkgconfig"
  else
    # debian
    pkg.build_requires "pkg-config"
  end

  pkg.install do
    [
      "PKG_CONFIG_PATH='#{settings[:pkg_config_path]}' \
      CFLAGS='#{settings[:cflags]}' \
      LDFLAGS='#{settings[:ldflags]}' \
      CC=/opt/pl-build-tools/bin/gcc \
      #{settings[:gem_install]} #{gemname}-#{pkg.get_version}.gem -- --with-opt-dir=#{settings[:prefix]} --use-system-libraries"
    ]
  end
end
