platform "osx-10.13-x86_64" do |plat|
  plat.servicetype 'launchd'
  plat.servicedir '/Library/LaunchDaemons'
  plat.codename "high_sierra"

  # create a non-root user to run homebrew under
  plat.provision_with '/usr/sbin/sysadminctl -adminUser root -adminPassword foo -addUser vanagon -password vanagon -home /opt/vanagon -admin'
  plat.provision_with 'createhomedir -c 2>&1 | grep -v "shell-init"'

  # terrible hack to allow vanagon user access to forwarded
  # ssh-agent
  plat.provision_with 'chmod go+rx $(dirname $SSH_AUTH_SOCK)'
  plat.provision_with 'chmod go+w $SSH_AUTH_SOCK'

  # install homebrew from tar and work around SIP restrictions
  # on /usr/local
  plat.provision_with 'curl https://artifactory.delivery.puppetlabs.net/artifactory/generic__local/build-tools/osx/brew-1.5.10.tar.gz | tar -x --strip 1 -C /usr/local -f -'
  plat.provision_with 'mkdir -p /usr/local/Cellar'
  plat.provision_with 'mkdir -p /usr/local/var'
  plat.provision_with 'chown -R vanagon:admin /usr/local/*'

  plat.provision_with 'export HOMEBREW_NO_AUTO_UPDATE=true'
  plat.provision_with 'export HOMEBREW_NO_EMOJI=true'
  plat.provision_with 'export HOMEBREW_VERBOSE=true'

  plat.provision_with 'cd /opt/vanagon'

  sudo_as_vanagon = 'sudo -E -u vanagon HOME=/opt/vanagon bash -c'

  plat.provision_with "#{sudo_as_vanagon} 'mkdir -p /opt/vanagon/.ssh'"
  plat.provision_with "#{sudo_as_vanagon} 'ssh-keyscan github.delivery.puppetlabs.net >> /opt/vanagon/.ssh/known_hosts'"
  plat.provision_with "#{sudo_as_vanagon} '/usr/local/bin/brew tap puppetlabs/brew-build-tools gitmirror@github.delivery.puppetlabs.net:puppetlabs-homebrew-build-tools'"
  plat.provision_with "#{sudo_as_vanagon} '/usr/local/bin/brew tap-pin puppetlabs/brew-build-tools'"

  plat.provision_with "#{sudo_as_vanagon} 'curl -o /usr/local/bin/osx-deps http://pl-build-tools.delivery.puppetlabs.net/osx/osx-deps'"
  plat.provision_with "#{sudo_as_vanagon} 'chmod 755 /usr/local/bin/osx-deps'"
  plat.provision_with "#{sudo_as_vanagon} '/usr/local/bin/osx-deps pkg-config'"

  plat.install_build_dependencies_with "sudo -E -u vanagon HOME=/opt/vanagon /usr/local/bin/osx-deps "

  plat.vmpooler_template "osx-1013-x86_64"
  plat.output_dir File.join("apple", "10.13", "PC1", "x86_64")
end
