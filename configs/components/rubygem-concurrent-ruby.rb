component "rubygem-concurrent-ruby" do |pkg, settings, platform|
  pkg.version "1.1.10"
  pkg.sha256sum "244cb1ca0d91ec2c15ca2209507c39fb163336994428e16fbd3f465c87bd8e68"

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
