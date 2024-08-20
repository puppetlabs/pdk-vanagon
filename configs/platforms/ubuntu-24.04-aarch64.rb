# this is needed as jenkins is using PDK vanagon 0.48.0 which doesn't have ubuntu-24.04-aarch64.rb
# once Jenkins is using Vanagon version  0.49.0 or 0.50.0 we can revert this back

platform "ubuntu-24.04-aarch64" do |plat|
  plat.servicedir "/lib/systemd/system"
  plat.defaultdir "/etc/default"
  plat.servicetype "systemd"
  plat.codename "noble"

  packages = %w(build-essential devscripts make quilt pkg-config debhelper rsync fakeroot cmake)
  plat.provision_with "export DEBIAN_FRONTEND=noninteractive; apt-get update -qq; apt-get install -qy --no-install-recommends #{packages.join(' ')}"
  plat.install_build_dependencies_with "DEBIAN_FRONTEND=noninteractive; apt-get install -qy --no-install-recommends "
  plat.vmpooler_template "ubuntu-2404-arm64"
end