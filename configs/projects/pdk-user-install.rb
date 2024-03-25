project 'pdk-user' do |proj|
  # This project exists so that we can build per user installs for PDK.
  # It's only used for the Windows platform.
  proj.setting(:install_scope, 'perUser')
  proj.setting(:runtime_project, 'pdk-runtime-user')
  instance_eval File.read('configs/projects/pdk.rb')
end
