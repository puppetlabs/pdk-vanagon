component "rubygem-hocon" do |pkg, settings, platform|
  pkg.version "1.3.1"
  pkg.sha256sum 'b65aba4db51987a0d1d504696f3ebd0a484d86f18f33d0e66deedeed36d92e56'

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
