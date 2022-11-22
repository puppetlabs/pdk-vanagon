component "rubygem-json-schema" do |pkg, settings, platform|
  pkg.version "3.0.0"
  pkg.sha256sum '2452cbc42de5f163feafa4bb0fa2c0f1fa5599e3fdf3ab3844b628e507aabb3d'

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
