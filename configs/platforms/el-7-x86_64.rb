platform 'el-7-x86_64' do |plat|
  plat.inherit_from_default
  packages = %w(gcc-c++)
  plat.provision_with("yum install --assumeyes  #{packages.join(' ')}")
end
