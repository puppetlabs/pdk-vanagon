component "shellpath" do |pkg, settings, platform|
  if platform.is_macos?
    pkg.add_source 'file://resources/files/paths.d/50-pdk', sum: '4abf75aebbbfbbefc4fe0173c57ed0b2'
    pkg.install_file('./50-pdk', '/etc/paths.d/50-pdk')
  elsif platform.is_deb?
    pkg.link File.join(settings[:prefix], 'bin', 'pdk'), File.join(settings[:main_bin], 'pdk')
  elsif platform.is_linux?
    pkg.add_source "file://resources/files/profile.d/pdk.sh", sum: "432bafccde488f7624d6c384ff8c15b6"
    pkg.install_file('./pdk.sh', '/etc/profile.d/pdk.sh')
  end
end
