component "rubygem-json-schema" do |pkg, settings, platform|
  pkg.version "2.8.0"
  pkg.sha256sum "bf7a949c1b9629097af506900668d4c463f5321b6eefed80c57599aa3c46b185"

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
