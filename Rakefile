require 'json'
require 'packaging'

Pkg::Util::RakeUtils.load_packaging_tasks

namespace :component do
  desc "Display currently promoted ref for component"
  task :check, [:component] do |t,args|
    abort 'USAGE: rake component:check[component]' unless args[:component]

    config = get_component_config(args[:component])

    puts config["ref"]
  end

  desc "Update component config to promote a new version"
  task :promote, [:component, :version, :ref] do |t,args|
    abort 'USAGE: rake component:promote[component,version,ref]' unless args[:component] && args[:version] && args[:ref]

    config = get_component_config(args[:component])
    config["version"] = args[:version]
    config["ref"] = args[:ref]

    File.open(component_config_file(args[:component]), 'w') do |f|
      f.write(JSON.pretty_generate(config))
    end
  end
end

# Legacy task name.
task :promote_component, [:component, :version, :ref] => "component:promote"

def component_config_file(component)
  "configs/components/#{component}.json"
end

def get_component_config(component)
  conf = component_config_file(component)
  abort "No component config file '#{conf}'" unless File.exist?(conf)

  JSON.parse(File.read(conf))
end

namespace :package do
  #   desc "Bootstrap packaging automation, e.g. clone into packaging repo"
  task :bootstrap do
    puts '`rake package:bootstrap` isn\'t needed now that we can run packaging as a gem!'
  end
  #   desc "Remove all cloned packaging automation"
  task :implode do
    puts '`rake package:implode` isn\'t needed now that we can run packaging as a gem!'
  end
end
