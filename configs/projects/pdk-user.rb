project 'pdk-user' do |proj|
  # This project exists so that we can build per user installs for PDK.
  # It's only used for the Windows platform.
  proj.setting(:install_scope, 'perUser')
  proj.setting(:runtime_project, 'pdk-runtime-user')
  proj.setting(:runtime_config_path, File.join(File.dirname(__FILE__), '..', 'components', 'puppet-runtime.json'))
  instance_eval File.read(File.join(File.dirname(__FILE__), 'pdk.rb'))
end
