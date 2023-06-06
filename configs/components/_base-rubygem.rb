# This file is a common basis for multiple rubygem components.
#
# It should not be included as a component itself; Instead, other components
# should load it with instance_eval after setting pkg.version. Parts of this
# shared configuration may be overridden afterward.

name = pkg.get_name.gsub('rubygem-', '')
unless name && !name.empty?
  raise 'Rubygem component files that instance_eval _base-rubygem must be named rubygem-<gem-name>.rb'
end

version = pkg.get_version
unless version && !version.empty?
  raise 'You must set the `pkg.version` in your rubygem component before instance_evaling _base_rubygem.rb'
end

pkg.url("https://rubygems.org/downloads/#{name}-#{version}.gem")
pkg.mirror("#{settings[:buildsources_url]}/#{name}-#{version}.gem")

pkg.build_requires 'pdk-runtime'

if platform.is_windows?
  pkg.environment 'PATH', settings[:gem_path_env]
end

pkg.install do
  "#{settings[:gem_install]} #{name}-#{version}.gem"
end
