component "rubygem-public_suffix" do |pkg, settings, platform|
  pkg.version "4.0.7"
  pkg.sha256sum '8be161e2421f8d45b0098c042c06486789731ea93dc3a896d30554ee38b573b8'

  instance_eval File.read('configs/components/_base-rubygem.rb')
 end
