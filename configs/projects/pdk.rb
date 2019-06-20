project "pdk" do |proj|
  # Inherit a bunch of shared settings from pdk-runtime config
  proj.setting(:pdk_runtime_version, '201906190')
  proj.inherit_settings 'pdk-runtime', 'git://github.com/puppetlabs/puppet-runtime', proj.pdk_runtime_version

  proj.description "Puppet Development Kit"
  proj.version_from_git
  proj.write_version_file File.join(proj.prefix, 'PDK_VERSION')
  proj.license "See components"
  proj.vendor "Puppet, Inc. <info@puppet.com>"
  proj.homepage "https://www.puppet.com"
  proj.target_repo "puppet5"

  platform = proj.get_platform

  if platform.is_macos?
    proj.identifier "com.puppetlabs"
  end

  # Project level settings our components will care about
  if platform.is_windows?
    # Used in WIX templates
    proj.setting(:company_name, "Puppet Inc")
    proj.setting(:pl_company_name, "Puppet Labs")
    proj.setting(:product_name, "Puppet Development Kit")
    proj.setting(:shortcut_name, "Puppet Development Kit")
    proj.setting(:upgrade_code, "2F79F42E-955C-4E69-AB87-DB4ED9EDF2D9")
    proj.setting(:win64, "yes")
    proj.setting(:RememberedInstallDirRegKey, "RememberedInstallDir64")
    proj.setting(:LicenseRTF, "wix/license/LICENSE.rtf")
    proj.setting(:links, {
      :HelpLink => "http://puppet.com/services/customer-support",
      :CommunityLink => "https://puppet.com/community",
      :ForgeLink => "http://forge.puppet.com",
      :NextStepLink => "https://puppet.com/docs/pdk/1.x/pdk.html",
      :ManualLink => "https://puppet.com/docs/pdk/1.x/pdk.html",
    })
  else
    # Where to add a link to the pdk executable on non-Windows platforms
    proj.setting(:main_bin, "/usr/local/bin")
  end

  # Internal rubygems mirror
  # TODO: Migrate more components to use this
  proj.setting(:rubygems_url, "#{proj.artifactory_url}/rubygems/gems")

  proj.setting(:bundler_version, "1.16.1")
  proj.setting(:mini_portile2_version, '2.3.0')
  proj.setting(:nokogiri_version, '1.8.5')

  proj.setting(:cachedir, File.join(proj.datadir, "cache"))

  if platform.is_windows?
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

  if platform.is_fedora? && platform.os_version.to_i >= 28
    # Disable shebang mangling for certain paths inside PDK.
    # See https://fedoraproject.org/wiki/Packaging:Guidelines#Shebang_lines
    brp_mangle_shebangs_exclude_from = [
      ".*/opt/puppetlabs/pdk/private/ruby/.*",
      ".*/opt/puppetlabs/pdk/share/cache/ruby/.*",
    ].join('|')

    proj.package_override("# Disable shebang mangling of embedded Ruby stuff\n%global __brp_mangle_shebangs_exclude_from ^(#{brp_mangle_shebangs_exclude_from})$")

    # Disable build-id generation since it's currently generating conflicts
    # with system libgcc and libstdc++
    proj.package_override("# Disable build-id generation to avoid conflicts\n%global _build_id_links none")
  end

  # What to build?
  # --------------

  # Bundler
  proj.component "rubygem-bundler"

  # runtime!
  proj.component "pdk-runtime"

  # Cri and deps
  proj.component "rubygem-colored"
  proj.component "rubygem-cri"

  # Childprocess and deps
  proj.component "rubygem-childprocess"

  # tty-prompt and deps
  proj.component "rubygem-necromancer"
  proj.component "rubygem-tty-color"
  proj.component "rubygem-equatable"
  proj.component "rubygem-pastel"
  proj.component "rubygem-wisper"
  proj.component "rubygem-tty-cursor"
  proj.component "rubygem-hitimes"
  proj.component "rubygem-timers"
  proj.component "rubygem-tty-prompt"

  # json-schema and deps
  proj.component "rubygem-public_suffix"
  proj.component "rubygem-addressable"
  proj.component "rubygem-json-schema"

  # Analytics deps
  proj.component "rubygem-concurrent-ruby"
  proj.component "rubygem-facter"
  proj.component "rubygem-httpclient"

  # Other deps
  proj.component "rubygem-deep_merge"
  proj.component "rubygem-tty-spinner"
  proj.component "rubygem-json_pure"
  proj.component "rubygem-tty-which"
  proj.component "rubygem-diff-lcs"
  proj.component "rubygem-pathspec"
  proj.component "rubygem-hitimes"
  proj.component "rubygem-net-ssh"

  # nokogiri and deps
  proj.component 'rubygem-mini_portile2'
  proj.component 'rubygem-nokogiri'

  # PDK
  proj.component "rubygem-pdk"

  # Batteries included copies of module template and required gems
  proj.component "pdk-templates"

  # Cache puppet gems, task metadata schema, etc.
  proj.component "puppet-forge-api"

  proj.component "gem-prune"

  # Set up PATH on posix platforms
  proj.component "shellpath" unless platform.is_windows?

  # What to include in package?
  proj.directory proj.install_root
  proj.directory proj.prefix
  proj.directory proj.link_bindir unless platform.is_windows?

  proj.timeout 7200 if platform.is_windows?

  # Here we rewrite public http urls to use our internal source host instead.
  # Something like https://www.openssl.org/source/openssl-1.0.0r.tar.gz gets
  # rewritten as
  # https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/openssl-1.0.0r.tar.gz
  proj.register_rewrite_rule 'http', proj.buildsources_url
end
