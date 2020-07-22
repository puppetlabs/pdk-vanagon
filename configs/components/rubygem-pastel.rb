component "rubygem-pastel" do |pkg, settings, platform|
  pkg.version "0.8.0"
  pkg.md5sum "0b238cba4ecffadc6ef557c6803d5a01"

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
