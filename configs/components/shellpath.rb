component 'shellpath' do |pkg, settings, platform|
  if platform.is_macos?
    pkg.add_source 'file://resources/files/paths.d/50-pdk', sum: '4abf75aebbbfbbefc4fe0173c57ed0b2'
    pkg.install_file('./50-pdk', '/etc/paths.d/50-pdk')
  elsif platform.is_linux?
    pkg.link File.join(settings[:prefix], 'bin', 'pdk'), File.join(settings[:main_bin], 'pdk')
  end
end
