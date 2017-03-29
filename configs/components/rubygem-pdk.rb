component "rubygem-pdk" do |pkg, settings, platform|
	# Set url and ref from json file.
  pkg.load_from_json('configs/components/rubygem-pdk.json')
  pkg.version "0.1.0"

  pkg.build_requires "ruby-2.1.9"

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
