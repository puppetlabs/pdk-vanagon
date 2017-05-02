project "puppet-sdk" do |proj|
  platform = proj.get_platform

  # Project level settings our components will care about
  if platform.is_windows?
    proj.setting(:company_name, "Puppet Inc")
    proj.setting(:pl_company_name, "Puppet Labs")
    proj.setting(:company_id, "PuppetLabs")
    proj.setting(:common_product_id, "PuppetDevelopmentKit")
    proj.setting(:product_id, "DevelopmentKit")
    proj.setting(:shortcut_name, "Puppet Development Kit")
    proj.setting(:upgrade_code, "2F79F42E-955C-4E69-AB87-DB4ED9EDF2D9")

    proj.setting(:product_name, "Puppet Development Kit")
    proj.setting(:win64, "yes")
    proj.setting(:base_dir, "ProgramFiles64Folder")
    proj.setting(:RememberedInstallDirRegKey, "RememberedInstallDir64")

    proj.setting(:links, {
      :HelpLink => "http://puppet.com/services/customer-support",
      :CommunityLink => "https://puppet.com/community",
      :ForgeLink => "http://forge.puppet.com",
      #FIXME: these links:
      :NextStepLink => "https://docs.puppet.com/puppet/latest/reference/services_commands_windows.html",
      :ManualLink => "https://docs.puppet.com/pe/latest/",
    })

    # FIXME: exit dialog text
    proj.setting(:UI_exitdialogtext, "Text appropriate to the PDK Installer.")
    proj.setting(:LicenseRTF, "wix/license/LICENSE.rtf")

    # Directory IDs
    proj.setting(:bindir_id, "bindir")

    # Windows specific directories.
    proj.setting(:install_root, File.join("C:", proj.base_dir, proj.company_id, proj.product_id))
    proj.setting(:sysconfdir, File.join("C:", "CommonAppDataFolder", proj.company_id))
    proj.setting(:tmpfilesdir, "C:/Windows/Temp")
    proj.setting(:main_bin, "#{proj.install_root}/bin")
    proj.setting(:windows_tools, File.join(proj.install_root, "sys/tools/bin"))
    proj.setting(:ruby_dir, File.join(proj.install_root, "sys/ruby"))
    proj.setting(:ruby_bindir, File.join(proj.ruby_dir, "bin"))
  else
    proj.setting(:install_root, "/opt/puppetlabs")

    if platform.is_macos?
      proj.setting(:sysconfdir, "/private/etc/puppetlabs")
    else
      proj.setting(:sysconfdir, "/etc/puppetlabs")
    end

    proj.setting(:tmpfilesdir, "/usr/lib/tmpfiles.d")
  end

  proj.setting(:miscdir, File.join(proj.install_root, "misc"))
  proj.setting(:prefix, File.join(proj.install_root, "sdk"))
  proj.setting(:bindir, File.join(proj.prefix, "bin"))
  proj.setting(:link_bindir, File.join(proj.install_root, "bin"))
  proj.setting(:includedir, File.join(proj.prefix, "include"))
  proj.setting(:datadir, File.join(proj.prefix, "share"))
  proj.setting(:mandir, File.join(proj.datadir, "man"))

  if platform.is_windows?
    proj.setting(:host_ruby, File.join(proj.ruby_bindir, "ruby.exe"))
    proj.setting(:host_gem, File.join(proj.ruby_bindir, "gem.bat"))
    proj.setting(:libdir, File.join(proj.ruby_dir, "lib"))
  else
    proj.setting(:host_ruby, File.join(proj.bindir, "ruby"))
    proj.setting(:host_gem, File.join(proj.bindir, "gem"))
    proj.setting(:libdir, File.join(proj.prefix, "lib"))
  end

  proj.setting(:ruby_version, "2.1.9")
  proj.setting(:gem_home, File.join(proj.libdir, "ruby", "gems", "2.1.0"))
  proj.setting(:ruby_vendordir, File.join(proj.libdir, "ruby", "vendor_ruby"))

  gem_install = "#{proj.host_gem} install --no-rdoc --no-ri --local "
  # Add --bindir option for Windows...
  gem_install << "--bindir #{proj.ruby_bindir} " if platform.is_windows?
  proj.setting(:gem_install, gem_install)

  if platform.is_windows?
    # For windows, we need to ensure we are building for mingw not cygwin
    platform_triple = platform.platform_triple
    host = "--host #{platform_triple}"
  end

  proj.setting(:platform_triple, platform_triple)
  proj.setting(:host, host)


  proj.description "Puppet SDK"
  proj.version_from_git
  proj.write_version_file File.join(proj.prefix, 'VERSION')
  proj.license "See components"
  proj.vendor "Puppet, Inc. <info@puppet.com>"
  proj.homepage "https://www.puppet.com"
  proj.target_repo "PC1"

  if platform.is_macos?
    proj.identifier "com.puppetlabs"
  end

  # Define default CFLAGS and LDFLAGS for most platforms, and then
  # tweak or adjust them as needed.
  proj.setting(:cppflags, "-I#{proj.includedir} -I/opt/pl-build-tools/include")
  proj.setting(:cflags, "#{proj.cppflags}")
  proj.setting(:ldflags, "-L#{proj.libdir} -L/opt/pl-build-tools/lib -Wl,-rpath=#{proj.libdir}")

  if platform.is_windows?
    arch = platform.architecture == "x64" ? "64" : "32"
    proj.setting(:gcc_root, "C:/tools/mingw#{arch}")
    proj.setting(:gcc_bindir, "#{proj.gcc_root}/bin")
    proj.setting(:tools_root, "C:/tools/pl-build-tools")
    proj.setting(:cppflags, "-I#{proj.tools_root}/include -I#{proj.gcc_root}/include -I#{proj.includedir}")
    proj.setting(:cflags, "#{proj.cppflags}")
    proj.setting(:ldflags, "-L#{proj.tools_root}/lib -L#{proj.gcc_root}/lib -L#{proj.libdir}")
    proj.setting(:cygwin, "nodosfilewarning winsymlinks:native")

    proj.setting(:gem_path_env, [
      "$(shell cygpath -u #{settings[:gcc_bindir]})",
      "$(shell cygpath -u #{settings[:ruby_bindir]})",
      "$(shell cygpath -u #{settings[:bindir]})",
      "/cygdrive/c/Windows/system32",
      "/cygdrive/c/Windows",
      "/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0",
      "$(PATH)",
    ].join(':'))
  end

  if platform.is_macos?
    # For OS X, we should optimize for an older architecture than Apple
    # currently ships for; there's a lot of older xeon chips based on
    # that architecture still in use throughout the Mac ecosystem.
    # Additionally, OS X doesn't use RPATH for linking. We shouldn't
    # define it or try to force it in the linker, because this might
    # break gcc or clang if they try to use the RPATH values we forced.
    proj.setting(:cppflags, "-I#{proj.includedir}")
    proj.setting(:cflags, "-march=core2 -msse4 #{proj.cppflags}")
    proj.setting(:ldflags, "-L#{proj.libdir} ")
  end

  # What to build?
  # --------------

  # Ruby and deps
  proj.component "runtime"
  proj.component "openssl"
  proj.component "puppet-ca-bundle"
  proj.component "ruby-#{proj.ruby_version}"

  # Bundler
  proj.component "rubygem-bundler"

  # Cri and deps
  proj.component "rubygem-colored"
  proj.component "rubygem-cri"

  # Childprocess and deps
  proj.component "rubygem-ffi"
  proj.component "rubygem-childprocess"

  # Gettext-setup and deps
  proj.component "rubygem-locale"
  proj.component "rubygem-text"
  proj.component "rubygem-gettext"
  proj.component "rubygem-fast_gettext"
  proj.component "rubygem-gettext-setup"

  # PDK
  proj.component "rubygem-pdk"

  # What to include in package?
  proj.directory proj.install_root
  proj.directory proj.prefix
  proj.directory proj.sysconfdir
  proj.directory proj.link_bindir

  proj.timeout 7200 if platform.is_windows?

  # Here we rewrite public http urls to use our internal source host instead.
  # Something like https://www.openssl.org/source/openssl-1.0.0r.tar.gz gets
  # rewritten as
  # http://buildsources.delivery.puppetlabs.net/openssl-1.0.0r.tar.gz
  proj.register_rewrite_rule 'http', 'http://buildsources.delivery.puppetlabs.net'
end
