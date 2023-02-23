component "rubygem-thor" do |pkg, settings, platform|
  pkg.version "1.2.1"
  pkg.sha256sum 'b1752153dc9c6b8d3fcaa665e9e1a00a3e73f28da5e238b81c404502e539d446'

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
