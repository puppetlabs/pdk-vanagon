project "pdk" do |proj|
  # Inherit a bunch of shared settings from pdk-runtime config
  runtime_config = JSON.parse(File.read(File.join(__dir__, '..', 'components', 'puppet-runtime.json')))
  proj.setting(:pdk_runtime_version, runtime_config["version"])
  proj.inherit_settings 'pdk-runtime', 'https://github.com/puppetlabs/puppet-runtime', proj.pdk_runtime_version

  proj.description "Puppet Development Kit"
  proj.version_from_git
  proj.write_version_file File.join(proj.prefix, 'PDK_VERSION')
  proj.license "See components"
  proj.vendor "Puppet, Inc. <info@puppet.com>"
  proj.homepage "https://www.puppet.com"

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
      :NextStepLink => "https://puppet.com/docs/pdk/latest/pdk.html",
      :ManualLink => "https://puppet.com/docs/pdk/latest/pdk.html",
    })

    module_directory = File.join(proj.datadir.sub(/^.*:\//, ''), 'PowerShell', 'Modules')
    proj.extra_file_to_sign File.join(module_directory, 'PuppetDevelopmentKit', 'PuppetDevelopmentKit.psm1')
    proj.signing_hostname 'composer-deb-prod-2.delivery.puppetlabs.net'
    proj.signing_username 'jenkins'
    proj.signing_command 'source /usr/local/rvm/scripts/rvm; rvm use 2.7.5; /var/lib/jenkins/bin/extra_file_signer'
  else
    # Where to add a link to the pdk executable on non-Windows platforms
    proj.setting(:main_bin, "/usr/local/bin")
  end

  # Internal rubygems mirror
  # TODO: Migrate more components to use this
  proj.setting(:rubygems_url, "#{proj.artifactory_url}/api/gems/rubygems")

  # This is here because we need to reference the bundler version in
  # multiple components
  # TODO: See if there is a way to directly reference a component from another.
  proj.setting(:bundler, {
    'version': '2.3.26',
    'sha256sum': '1ee53cdf61e728ad82c6dbff06cfcd8551d5422e88e86203f0e2dbe9ae999e09'
  })

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

  if platform.is_fedora? || (platform.is_el? && platform.os_version.to_i >= 8)
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
    proj.package_override("# Disable the removal of la files, they are still required\n%global __brp_remove_la_files %{nil}")
    proj.package_override("# Disable check-rpaths since /opt/* is not a valid path\n%global __brp_check_rpaths %{nil}")
  end

  def use_plgcc?(platform)
    return false if platform.is_fedora?
    return false if platform.is_el? && platform.os_version.to_i >= 7
    return false if platform.is_debian? && platform.os_version.to_i >= 8
    return false if platform.is_ubuntu? && platform.os_version.split('.').first.to_i >= 16
    return false if platform.is_sles? && platform.os_version.to_i >= 15

    true
  end

  proj.setting(:use_pl_build_tools, use_plgcc?(platform))

  # What to build?
  # --------------

  # Bundler
  proj.component "rubygem-bundler"

  # runtime!
  proj.component "pdk-runtime"

  # Cri and deps
  proj.component "rubygem-cri"

  # Childprocess and deps
  proj.component "rubygem-childprocess"

  proj.component "rubygem-hitimes"

  ## tty-reader and deps
  proj.component "rubygem-tty-screen"
  proj.component "rubygem-tty-cursor"
  proj.component "rubygem-wisper"
  proj.component "rubygem-tty-reader"

  ## pastel and deps
  proj.component "rubygem-tty-color"
  proj.component "rubygem-pastel"

  ## root tty gems
  proj.component "rubygem-tty-prompt"
  proj.component "rubygem-tty-spinner"
  proj.component "rubygem-tty-which"

  # json-schema and deps
  proj.component "rubygem-public_suffix"
  proj.component "rubygem-addressable"
  proj.component "rubygem-json-schema"

  # Analytics deps
  proj.component "rubygem-concurrent-ruby"
  proj.component "rubygem-thor"
  proj.component "rubygem-hocon"
  proj.component "rubygem-facter"
  proj.component "rubygem-httpclient"

  # Other deps
  proj.component "rubygem-deep_merge"
  proj.component "rubygem-json_pure"
  proj.component "rubygem-diff-lcs"
  proj.component "rubygem-pathspec"
  proj.component "rubygem-hitimes"
  proj.component "rubygem-minitar"

  # PDK
  proj.component "rubygem-pdk"

  # Cache puppet gems, task metadata schema, etc.
  proj.component "puppet-specifications"
  proj.component "puppet-versions"

  # Batteries included copies of module template and required gems
  proj.component "pdk-templates"

  proj.component "gem-prune"

  proj.component "pdk-create-ruby-tarballs"

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
