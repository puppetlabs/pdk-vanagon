component "rubygem-minitar" do |pkg, settings, platform|
  pkg.version "0.6.1"
  pkg.sha256sum "df5cdcdd5ecdcc1100cf3513557748f726bb1feea55f5cc25bb5a7116f069ddd"

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
