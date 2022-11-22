component "rubygem-facter" do |pkg, settings, platform|
  pkg.version "4.2.13"
  pkg.sha256sum "a4f293b585176b080c8f10e9adb7a4d1cfd484268dfef518b162a0422450264c"

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
