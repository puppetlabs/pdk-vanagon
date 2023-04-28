# A helper method used in the pdk-templates component. It's job is to build a
# new module from the given template ref and cache in the packages cachedir.
def build_module(settings, pdk_bin, cachedir, privatedir, template_ref, is_windows)
  ruby_cachedir = File.join(cachedir, 'ruby', settings[:ruby_api])
  puppet_cachedir = File.join(privatedir, 'puppet', 'ruby')

  gem_path_with_puppet_cache = [
    File.join(privatedir, 'ruby', settings[:ruby_version], 'lib', 'ruby', 'gems', settings[:ruby_api]),
    File.join(puppet_cachedir, settings[:ruby_api])
  ].join(is_windows ? ';' : ':')

  gem_env = [
    "GEM_PATH=\"#{gem_path_with_puppet_cache}\"",
    "GEM_HOME=\"#{ruby_cachedir}\""
  ]

  gem_env << "PUPPET_GEM_VERSION=\"#{settings[:latest_puppet]}\"" if settings[:latest_puppet]

  mod_name = "vanagon_module_#{settings[:ruby_version].gsub(/[^0-9]/, '')}"

  build_commands = []

  # Use previously installed pdk gem to generate a new module using the
  # cached module template.
  build_commands << "#{pdk_bin} new module #{mod_name} --skip-interview --template-ref=#{template_ref} --template-url=file:///#{File.join(cachedir, 'pdk-templates.git')} --skip-bundle-install"

  # Run 'bundle lock' in the generated module and cache the Gemfile.lock
  # inside the project cachedir. We add the private/puppet paths to
  # GEM_PATH to make sure we resolve to a cached version of puppet.
  build_commands << "pushd #{mod_name} && #{gem_env.join(' ')} #{settings[:host_bundle]} lock && popd"

  # Copy generated Gemfile.lock into cachedir.
  build_commands << "cp #{mod_name}/Gemfile.lock #{cachedir}/Gemfile-#{settings[:ruby_version]}.lock"
  build_commands << "cp #{mod_name}/Gemfile.lock #{cachedir}/Gemfile.lock"

  # Run 'bundle install' in the generated module to cache the gems
  # inside the project cachedir.
  build_commands << "pushd #{mod_name} && #{gem_env.join(' ')} #{settings[:host_bundle]} install && popd"

  # Install bundler into the gem cache
  build_commands << "#{gem_env.join(' ')} #{settings[:host_gem]} install --no-document --local --bindir /tmp ../bundler-2.4.13.gem"

  return build_commands unless is_windows

  # The puppet gem has files in it's 'spec' directory with very long paths which
  # bump up against MAX_PATH on Windows. Since the 'spec' directory is not required
  # at runtime, we just purge it before attempting to package.
  build_commands << "/usr/bin/find #{ruby_cachedir} -regextype posix-extended -regex '.*/puppet-[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+[^/]*/spec/.*' -delete"

  build_commands
end
