component "task-schema" do |pkg, settings, platform|
  pkg.ref "master"
  pkg.url "git@github.com:puppetlabs/puppet-forge-api.git"
  pkg.dirname "puppet-forge-api"

  pkg.install_file('app/static/schemas/task.json', File.join(settings[:cachedir], 'task.json'))
end
