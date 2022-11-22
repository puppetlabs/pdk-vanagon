component 'rubygem-bundler' do |pkg, settings, platform|
  pkg.version settings[:bundler][:version]
  pkg.sha256sum settings[:bundler][:sha256sum]

  instance_eval File.read('configs/components/_base-rubygem.rb')

  pkg.install do
    name = pkg.get_name.gsub('rubygem-', '')
    install_commands = []
    install_commands << "#{settings[:gem_install]} #{name}-#{pkg.get_version}.gem"

    settings[:additional_rubies].each do |_rubyver, local_settings|
      install_commands << "#{local_settings[:gem_install]} bundler-#{pkg.get_version}.gem"
    end

    install_commands
  end
end
