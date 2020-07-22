component "rubygem-tty-screen" do |pkg, settings, platform|
  pkg.version "0.8.1"
  pkg.md5sum "64f04117c9e985a04761eb4e8e1e5d70"

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
