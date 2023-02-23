component "rubygem-pathspec" do |pkg, settings, platform|
  pkg.version "0.2.1"
  pkg.sha256sum "7b0c49f3e8efea77002326aaf0674d66f7c1b507cf31f7273e9931ac860a141c"

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
