component "rubygem-cri" do |pkg, settings, platform|
  pkg.version "2.7.1"
  pkg.md5sum "21438cdbbc0304ffdd20022ae73c671c"
  pkg.url "http://buildsources.delivery.puppetlabs.net/cri-#{pkg.get_version}.gem"

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
    "#{settings[:gem_install]} cri-#{pkg.get_version}.gem"
  end
end
