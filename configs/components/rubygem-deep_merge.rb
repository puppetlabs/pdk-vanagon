component "rubygem-deep_merge" do |pkg, settings, platform|
  pkg.version "1.2.2"
  pkg.sha256sum "83ced3a3d7f95f67de958d2ce41b1874e83c8d94fe2ddbff50c8b4b82323563a"

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
