component "rubygem-ffi" do |pkg, settings, platform|
  gemname = pkg.get_name.gsub('rubygem-', '')
  pkg.version "1.9.18"
  pkg.md5sum "37284a51e5464443f7122b388329a2a0"
  pkg.url "#{settings[:buildsources_url]}/#{gemname}-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.md5sum "664afc6a316dd648f497fbda3be87137"
    pkg.url "https://rubygems.org/downloads/ffi-#{pkg.get_version}-x64-mingw32.gem"

    pkg.environment "PATH", settings[:gem_path_env]

    pkg.install do
      ["#{settings[:gem_install]} ffi-#{pkg.get_version}-x64-mingw32.gem"]
    end
  else
    pkg.build_requires "cmake"

    if platform.is_rpm?
      # red hat
      pkg.build_requires "pkgconfig"
    else
      # debian
      pkg.build_requires "pkg-config"
    end

    pkg.install do
      install_cmds = [
        "PKG_CONFIG_PATH='#{settings[:pkg_config_path]}'",
        "CFLAGS='#{settings[:cflags]}'",
        "LDFLAGS='#{settings[:ldflags]}'",
      ]

      install_cmds << "CC=/opt/pl-build-tools/bin/gcc" unless platform.codename == 'bionic'

      install_cmds << "#{settings[:gem_install]} #{gemname}-#{pkg.get_version}.gem -- --with-opt-dir=#{settings[:prefix]} --use-system-libraries"

      install_cmds.join(' ')
    end
  end
end
