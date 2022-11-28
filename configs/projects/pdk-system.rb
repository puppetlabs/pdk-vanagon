project 'pdk-system' do |proj|
  # This project exists so that we can build per user machine for PDK.
  # It's only used for the Windows platform.
  # Additionally, there is no difference between the using this project and the
  # base pdk project.
  proj.setting(:install_scope, 'perMachine')
  proj.setting(:runtime_project, 'pdk-runtime-system')
  proj.setting(:runtime_config_path, File.join(File.dirname(__FILE__), '..', 'components', 'puppet-runtime.json'))
  instance_eval File.read('configs/projects/pdk.rb')
end
