component "rubygem-httpclient" do |pkg, settings, platform|
  pkg.version "2.8.3"
  pkg.sha256sum "2951e4991214464c3e92107e46438527d23048e634f3aee91c719e0bdfaebda6"

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
