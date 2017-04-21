component "rubygem-bundler" do |pkg, settings, platform|
  pkg.version "1.14.6"
  pkg.md5sum "ce977d12aa92d7da47f86971d32dd338"
  pkg.url "http://buildsources.delivery.puppetlabs.net/bundler-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

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
    "#{settings[:gem_install]} bundler-#{pkg.get_version}.gem"
  end
end
