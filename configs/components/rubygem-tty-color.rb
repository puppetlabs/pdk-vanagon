component "rubygem-tty-color" do |pkg, settings, platform|
  pkg.version "0.5.1"
  pkg.md5sum "9dd67017acbadabc2c93ef49fcd7f964"

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
