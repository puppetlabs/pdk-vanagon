component "rubygem-facter" do |pkg, settings, platform|
  pkg.version "4.3.0"
  pkg.sha256sum "d24597d0fdc6a9219cb16f57f71512cd97219611775e24868bd30975b06cad2c"

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
