component "rubygem-json_pure" do |pkg, settings, platform|
  pkg.version "2.6.2"
  pkg.sha256sum 'ccf59aeb76249a17d894f0a974073d1264645528f0799a59c52b01560da3a811'

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
