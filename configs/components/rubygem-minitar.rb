component "rubygem-minitar" do |pkg, settings, platform|
  pkg.version "0.6"
  pkg.sha256sum "3e5e25708d25488cd4ad13b7a40bf785e2a0ca7c7a89ed778a64c428b3144dd8"

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
