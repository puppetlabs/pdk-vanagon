component "rubygem-public_suffix" do |pkg, settings, platform|
  pkg.version "5.0.0"
  pkg.sha256sum '26ee4fbce33ada25eb117ac71f2c24bf4d8b3414ab6b34f05b4708a3e90f1c6b'

  instance_eval File.read('configs/components/_base-rubygem.rb')
 end
