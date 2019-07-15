require 'pathname'
require 'fileutils'

script_dir = __dir__
install_dir = File.expand_path(File.join(script_dir, '..', '..'))

def logmessage(message)
  puts message
end

def ruby_api_version(ruby_version)
  gem_ver = Gem::Version.new(ruby_version)
  gem_ver.segments[0..1].join('.') + '.0'
end

# Remove the ruby and puppet cache, but not the actual runtime for the ruby we're _actually_ using
# right now. We need that!
ruby_ver = RUBY_VERSION
logmessage("Ruby version is #{ruby_ver}")
ruby_api = ruby_api_version(ruby_ver)
dirs_to_delete = ["private/puppet/ruby/#{ruby_api}", "share/cache/ruby/#{ruby_api}"]

# Enumerate all of the ruby runtimes
Dir.glob(File.join(install_dir, 'private', 'ruby', '*/')) do |ruby_runtime|
  path = Pathname.new(ruby_runtime)
  ruby_ver = path.basename.to_s
  next if ruby_ver == RUBY_VERSION
  ruby_api = ruby_api_version(ruby_ver)
  # Remove the ruby and puppet cache, and the ruby runtime
  dirs_to_delete.concat(["private/ruby/#{ruby_ver}", "private/puppet/ruby/#{ruby_api}", "share/cache/ruby/#{ruby_api}"])
end

dirs_to_delete.each { |dir| logmessage("'#{dir}' is scheduled for deletion") }
dirs_to_delete.each do |dir|
  absolute_dir = File.join(install_dir, dir)
  logmessage("Attempting to delete '#{absolute_dir}'...")
  FileUtils.rm_rf(absolute_dir)
end
