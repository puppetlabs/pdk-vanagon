component "rubygem-minitar" do |pkg, settings, platform|
  pkg.version "0.8"
  pkg.sha256sum "8dc3681aac3bb869546012688b87d9b0cda51b78da8db663cd5d1a38100edcb5"

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
