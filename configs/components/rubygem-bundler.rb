component "rubygem-bundler" do |pkg, settings, _platform|
  pkg.version '2.4.13'
  pkg.sha256sum '11653aa5ae507c6dbd55bf7e9be8926d99afac9b6c0c08d3a1938afeb3e75a8b'

  instance_eval File.read('configs/components/_base-rubygem.rb')

  pkg.install do
    install_commands = []
    install_commands << "#{settings[:gem_install]} bundler-#{pkg.get_version}.gem"

    settings[:additional_rubies].each do |_rubyver, local_settings|
      install_commands << "#{local_settings[:gem_install]} bundler-#{pkg.get_version}.gem"
    end

    install_commands
  end
end
