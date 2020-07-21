component "rubygem-tty-reader" do |pkg, settings, platform|
  pkg.version "0.8.0"
  pkg.md5sum "c14bae0ed9f6e07ef288b1824c7f1a44"

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
