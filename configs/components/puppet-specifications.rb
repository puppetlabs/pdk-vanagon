component "puppet-specifications" do |pkg, settings, platform|
  pkg.ref "master"
  pkg.url "https://github.com/puppetlabs/puppet-specifications"

  pkg.build_requires "pdk-runtime"

  # Cache the task metadata schema.
  pkg.install_file(File.join('tasks', 'task.json'), File.join(settings[:cachedir], 'task.json'))
end
