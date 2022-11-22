component 'rubygem-mini_portile2' do |pkg, settings, platform|
  pkg.version settings[:mini_portile2_version]['default'][:version]
  pkg.sha256sum settings[:mini_portile2_version]['default'][:sha256sum]

  instance_eval File.read('configs/components/_base-rubygem.rb')
end
