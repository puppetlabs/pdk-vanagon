component "rubygem-colored" do |pkg, settings, platform|
  gemname = pkg.get_name.gsub('rubygem-', '')
  pkg.version "1.2"
  pkg.md5sum "1b1a0f16f7c6ab57d1a2d6de53b13c42"
  pkg.url "http://buildsources.delivery.puppetlabs.net/#{gemname}-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-2.1.9"

  if platform.is_windows?
    pkg.environment "PATH", [
      "$(shell cygpath -u #{settings[:gcc_bindir]})",
      "$(shell cygpath -u #{settings[:ruby_bindir]})",
      "$(shell cygpath -u #{settings[:bindir]})",
      "/cygdrive/c/Windows/system32",
      "/cygdrive/c/Windows",
      "/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0",
    ].join(':')
  end

  pkg.install do
    "#{settings[:gem_install]} #{gemname}-#{pkg.get_version}.gem"
  end
end
