component 'rubygem-racc' do |pkg, settings, platform|
  pkg.version "1.5.0"
  pkg.md5sum "5a1239f6434da1353ca59594d9a88ee3"
  pkg.url "#{settings[:buildsources_url]}/racc-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    ruby_gem_ver = 'ruby-2.4.0'
    build_env_path = [
      "$(shell cygpath -u C:/ProgramData/chocolatey/lib/mingw/tools/install/mingw64/bin)",
      "$(shell cygpath -u #{settings[:tools_root]}/bin)",
      "$(shell cygpath -u #{settings[:tools_root]}/include)",
      "$(shell cygpath -u #{settings[:bindir]})",
      "$(shell cygpath -u #{settings[:ruby_bindir]})",
      "$(shell cygpath -u #{settings[:includedir]})",
      "/cygdrive/c/Windows/system32",
      "/cygdrive/c/Windows",
      "/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0",
      "$(PATH)",
    ].join(':')

    pkg.environment "PATH", build_env_path
    pkg.environment 'CONFIGURE_ARGS', "--with-cflags='-I#{settings[:includedir]}/#{settings[ruby_gem_ver]}'"

  end

  pkg.install do
    "#{settings[:gem_install]} racc-#{pkg.get_version}.gem"
  end
end
