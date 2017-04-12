component "rubygem-ffi" do |pkg, settings, platform|
  gemname = pkg.get_name.gsub('rubygem-', '')
  pkg.version "1.9.18"
  pkg.md5sum "37284a51e5464443f7122b388329a2a0"
  pkg.url "http://buildsources.delivery.puppetlabs.net/#{gemname}-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-2.1.9"

  if platform.is_windows?
    pkg.md5sum "664afc6a316dd648f497fbda3be87137"
    pkg.url "https://rubygems.org/downloads/ffi-#{pkg.get_version}-x64-mingw32.gem"

    # Because we are cross-compiling on sparc, we can't use the rubygems we just built.
    # Instead we use the host gem installation and override GEM_HOME. Yay?
    #pkg.environment "GEM_HOME" => settings[:gem_home]

    pkg.environment "PATH", [
      "$(shell cygpath -u #{settings[:gcc_bindir]})",
      "$(shell cygpath -u #{settings[:bindir]})",
      "$(shell cygpath -u #{settings[:ruby_bindir]})",
      "/cygdrive/c/Windows/system32",
      "/cygdrive/c/Windows",
      "/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0",
    ].join(':')

    # PA-25 in order to install gems in a cross-compiled environment we need to
    # set RUBYLIB to include puppet and hiera, so that their gemspecs can resolve
    # hiera/version and puppet/version requires. Without this the gem install
    # will fail by blowing out the stack.
    #pkg.environment "RUBYLIB" => "#{settings[:ruby_vendordir]}:$$RUBYLIB"

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
      [
        "PKG_CONFIG_PATH='#{settings[:pkg_config_path]}' \
        CFLAGS='#{settings[:cflags]}' \
        LDFLAGS='#{settings[:ldflags]}' \
        CC=/opt/pl-build-tools/bin/gcc \
        #{settings[:gem_install]} #{gemname}-#{pkg.get_version}.gem -- --with-opt-dir=#{settings[:prefix]} --use-system-libraries"
      ]
    end
  end
end
