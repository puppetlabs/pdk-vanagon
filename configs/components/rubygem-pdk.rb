component "rubygem-pdk" do |pkg, settings, platform|
	# Set version, url, and ref from json file.
  pkg.load_from_json('configs/components/rubygem-pdk.json')

  if platform.name =~ /ubuntu/
    pkg.build_requires "git-core"
  else
    pkg.build_requires "git"
  end

  pkg.install do
    [
      "gem build pdk.gemspec",
      "#{settings[:gem_install]} pdk-#{pkg.get_version}.gem",
    ]
  end

  pkg.link "#{settings[:bindir]}/pdk", "#{settings[:link_bindir]}/pdk"
end
