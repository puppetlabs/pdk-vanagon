component "puppet-specifications" do |pkg, settings, platform|
  pkg.ref "master"
  pkg.url "git@github.com:puppetlabs/puppet-specifications.git"

  pkg.build_requires "pdk-runtime"

  # Cache the task metadata schema.
  pkg.install_file(File.join('tasks', 'task.json'), File.join(settings[:cachedir], 'task.json'))
end
