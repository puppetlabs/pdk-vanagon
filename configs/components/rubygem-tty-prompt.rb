component "rubygem-tty-prompt" do |pkg, settings, platform|
  pkg.version "0.22.0"
  pkg.md5sum "7a98f5b7520238a9442e97643ffb564b"

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
