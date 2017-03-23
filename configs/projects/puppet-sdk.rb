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

    if platform.is_macos?
      proj.setting(:sysconfdir, "/private/etc/puppetlabs")
    else
      proj.setting(:sysconfdir, "/etc/puppetlabs")
    end
  end

  proj.description "Puppet SDK"
  proj.version_from_git
  proj.write_version_file File.join(proj.prefix, 'VERSION')
  proj.license "See components"
  proj.vendor "Puppet, Inc. <info@puppet.com>"
  proj.homepage "https://www.puppet.com"
end
