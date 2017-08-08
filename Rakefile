RAKE_ROOT = File.expand_path(File.dirname(__FILE__))

begin
  load File.join(RAKE_ROOT, 'ext', 'packaging', 'packaging.rake')
rescue LoadError
end

build_defs_file = File.join(RAKE_ROOT, 'ext', 'build_defaults.yaml')
if File.exist?(build_defs_file)
  begin
    require 'yaml'
    @build_defaults ||= YAML.load_file(build_defs_file)
  rescue Exception => e
    STDERR.puts "Unable to load yaml from #{build_defs_file}:"
    raise e
  end
  @packaging_url  = @build_defaults['packaging_url']
  @packaging_repo = @build_defaults['packaging_repo']
  raise "Could not find packaging url in #{build_defs_file}" if @packaging_url.nil?
  raise "Could not find packaging repo in #{build_defs_file}" if @packaging_repo.nil?

  namespace :package do
 #   desc "Bootstrap packaging automation, e.g. clone into packaging repo"
    task :bootstrap do
      if File.exist?(File.join(RAKE_ROOT, "ext", @packaging_repo))
        puts "It looks like you already have ext/#{@packaging_repo}. If you don't like it, blow it away with package:implode."
      else
        cd File.join(RAKE_ROOT, 'ext') do
          %x{git clone #{@packaging_url}}
        end
      end
    end
 #   desc "Remove all cloned packaging automation"
    task :implode do
      rm_rf File.join(RAKE_ROOT, "ext", @packaging_repo)
    end
  end
end

namespace :check do
  desc "Check rubygems-* components to see if newer versions are available on rubygems.org"
  task :rubygems do
    require 'gems'

    Dir.glob("#{RAKE_ROOT}/configs/components/rubygem-*.rb").each do |rubygem_conf|
      conf = File.read(rubygem_conf)
      gem_name = /^rubygem-(.*)\.rb$/.match(File.basename(rubygem_conf)).to_a[1]

      unless gem_name
        $stderr.puts "WARN: Could not determine gem_name for '#{File.basename(rubygem_conf)}', skipping"
        next
      end

      # Skip components that are pinned via json file.
      if conf =~ /load_from_json/
        $stderr.puts "INFO: '#{gem_name}' is pinned via JSON file, skipping"
        next
      end

      pin_version = /\.version[ (]+['"]+([^'"]+)/.match(conf).to_a[1]

      unless pin_version
        $stderr.puts "WARN: Could not determine pinned version for '#{gem_name}', skipping"
        next
      end

      latest = Gems.versions(gem_name).first

      if pin_version != latest['number']
        puts "#{gem_name} @ #{pin_version} -- #{latest['number']} was released #{latest['created_at']}"
      end
    end
  end
end
