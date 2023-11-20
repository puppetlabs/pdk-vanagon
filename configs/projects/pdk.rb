project 'pdk' do |proj|
  # Inherit a bunch of shared settings from pdk-runtime config
  runtime_config = JSON.parse(File.read(File.join(__dir__, '..', 'components', 'puppet-runtime.json')))
  proj.setting(:pdk_runtime_version, runtime_config['version'])
  proj.setting(:pdk_runtime_location, runtime_config['location'])
  proj.setting(:pdk_runtime_basename, "pdk-runtime-#{runtime_config['version']}.#{platform.name}")
  settings_uri = File.join(runtime_config['location'], "#{proj.settings[:pdk_runtime_basename]}.settings.yaml")
  sha1sum_uri = "#{settings_uri}.sha1"
  metadata_uri = File.join(runtime_config['location'], "#{proj.settings[:pdk_runtime_basename]}.json")
  proj.inherit_yaml_settings(settings_uri, sha1sum_uri, metadata_uri: metadata_uri)

  proj.description 'Puppet Development Kit'
  proj.version_from_git
  proj.write_version_file File.join(proj.prefix, 'PDK_VERSION')
  proj.license 'See components'
  proj.vendor 'Puppet, Inc. <info@puppet.com>'
  proj.homepage 'https://www.puppet.com'

  platform = proj.get_platform

  proj.identifier 'com.puppetlabs' if platform.is_macos?

  # Project level settings our components will care about
  if platform.is_windows?
    # Used in WIX templates
    proj.setting(:company_name, 'Puppet Inc')
    proj.setting(:pl_company_name, 'Puppet Labs')
    proj.setting(:product_name, 'Puppet Development Kit')
    proj.setting(:shortcut_name, 'Puppet Development Kit')
    proj.setting(:upgrade_code, '2F79F42E-955C-4E69-AB87-DB4ED9EDF2D9')
    proj.setting(:win64, 'yes')
    proj.setting(:RememberedInstallDirRegKey, 'RememberedInstallDir64')
    proj.setting(:LicenseRTF, 'wix/license/LICENSE.rtf')
    proj.setting(:links, {
      :HelpLink => 'http://puppet.com/services/customer-support',
      :CommunityLink => 'https://puppet.com/community',
      :ForgeLink => 'http://forge.puppet.com',
      :NextStepLink => 'https://puppet.com/docs/pdk/latest/pdk.html',
      :ManualLink =>'https://puppet.com/docs/pdk/latest/pdk.html',
    })

    proj.signing_hostname 'composer-deb-prod-2.delivery.puppetlabs.net'
    proj.signing_username 'jenkins'
    proj.signing_command 'source /usr/local/rvm/scripts/rvm; rvm use 2.7.5; /var/lib/jenkins/bin/extra_file_signer'
  else
    # Where to add a link to the pdk executable on non-Windows platforms
    proj.setting(:main_bin, '/usr/local/bin')
  end

  # Internal rubygems mirror
  # TODO: Migrate more components to use this
  proj.setting(:rubygems_url, "#{proj.artifactory_url}/api/gems/rubygems")

  proj.setting(:cachedir, File.join(proj.datadir, 'cache'))

  if platform.is_windows?
    proj.setting(:gem_path_env, [
      "$(shell cygpath -u #{settings[:gcc_bindir]})",
      "$(shell cygpath -u #{settings[:ruby_bindir]})",
      "$(shell cygpath -u #{settings[:bindir]})",
      '/cygdrive/c/Windows/system32',
      '/cygdrive/c/Windows',
      '/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0',
      '$(PATH)'
    ].join(':'))
  end

  if platform.is_fedora? || (platform.is_el? && platform.os_version.to_i >= 8)
    # Disable shebang mangling for certain paths inside PDK.
    # See https://fedoraproject.org/wiki/Packaging:Guidelines#Shebang_lines
    brp_mangle_shebangs_exclude_from = [
      '.*/opt/puppetlabs/pdk/private/ruby/.*',
      '.*/opt/puppetlabs/pdk/share/cache/ruby/.*'
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
  proj.component 'pdk-runtime'
  proj.component 'rubygem-bundler'
  proj.component 'rubygem-pdk'
  proj.component 'puppet-versions'
  proj.component 'pdk-templates'
  proj.component 'gem-prune'
  proj.component 'pdk-create-ruby-tarballs'

  # Set up PATH on posix platforms
  proj.component 'shellpath' unless platform.is_windows?

  # What to include in package?
  proj.directory proj.install_root
  proj.directory proj.prefix
  proj.directory proj.link_bindir unless platform.is_windows?

  proj.timeout 7200 if platform.is_windows?
end
