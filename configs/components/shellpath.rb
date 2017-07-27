component "shellpath" do |pkg, settings, platform|
  if platform.is_macos?
    pkg.add_source 'file://resources/files/paths.d/50-pdk', sum: '077ceb5e2f71cf733190a61d2fd221fb'
    pkg.install_file('./50-pdk', '/etc/paths.d/50-pdk')
  elsif platform.is_linux?
    pkg.add_source "file://resources/files/profile.d/pdk.sh", sum: "b6a51cfe9c7d8e435be4f7866a847d69"
    pkg.install_file('./pdk.sh', '/etc/profile.d/pdk.sh')
  end
end
