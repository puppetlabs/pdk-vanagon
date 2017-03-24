project "puppet-sdk" do |proj|
  platform = proj.get_platform

  # Project level settings our components will care about
  if platform.is_windows?
    # TODO
  else
    proj.setting(:install_root, "/opt/puppetlabs")
    proj.setting(:logdir, "/var/log/puppetlabs")
    proj.setting(:piddir, "/var/run/puppetlabs")
    proj.setting(:tmpfilesdir, "/usr/lib/tmpfiles.d")
    proj.setting(:prefix, File.join(proj.install_root, "sdk"))
    proj.setting(:bindir, File.join(proj.prefix, "bin"))
    proj.setting(:link_bindir, File.join(proj.install_root, "bin"))
    proj.setting(:includedir, File.join(proj.prefix, "include"))
    proj.setting(:datadir, File.join(proj.prefix, "share"))
    proj.setting(:mandir, File.join(proj.datadir, "man"))

    proj.setting(:host_ruby, File.join(proj.bindir, "ruby"))
    proj.setting(:host_gem, File.join(proj.bindir, "gem"))
    proj.setting(:libdir, File.join(proj.prefix, "lib"))

    proj.setting(:gem_home, File.join(proj.libdir, "ruby", "gems", "2.1.0"))
    proj.setting(:gem_install, "#{proj.host_gem} install --no-rdoc --no-ri --local ")

    if platform.is_macos?
      proj.setting(:sysconfdir, "/private/etc/puppetlabs")
    else
      proj.setting(:sysconfdir, "/etc/puppetlabs")
    end
  end

  proj.description "Puppet SDK"
  #proj.version_from_git
  proj.version "0.0.1"
  proj.write_version_file File.join(proj.prefix, 'VERSION')
  proj.license "See components"
  proj.vendor "Puppet, Inc. <info@puppet.com>"
  proj.homepage "https://www.puppet.com"

  # What to build?
  proj.component "ruby-2.1.9"
  proj.component "rubygem-pdk"

  # What to include in package?
  proj.directory proj.install_root
  proj.directory proj.prefix
  proj.directory proj.sysconfdir
  proj.directory proj.link_bindir
  proj.directory proj.logdir unless platform.is_windows?
  proj.directory proj.piddir unless platform.is_windows?
end
