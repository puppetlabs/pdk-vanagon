component "pdk-templates" do |pkg, settings, platform|
  # Set url and ref from json file so it's easy for jenkins
  # to promote new template versions.
  pkg.load_from_json('configs/components/pdk-templates.json')

  pkg.build_requires "pdk-runtime"
  pkg.build_requires "rubygem-bundler"
  pkg.build_requires "rubygem-mini_portile2"
  pkg.build_requires "rubygem-nokogiri"
  pkg.build_requires "rubygem-pdk"
  pkg.build_requires "puppet-forge-api"

  platforms_without_plgcc = %w[
    fedora-26-x86_64
    fedora-27-x86_64
    ubuntu-18.04-amd64
  ]

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  elsif platform.is_linux? && !platforms_without_plgcc.include?(platform.name)
    pkg.build_requires "pl-gcc"
    pkg.environment "PATH", "/opt/pl-build-tools/bin:$(PATH)"
  end

  pkg.build do
    git_bin = File.join(settings[:privatedir], 'git', 'bin', 'git')
    pdk_bin = File.join(settings[:ruby_bindir], 'pdk')
    ruby_cachedir = File.join(settings[:cachedir], 'ruby', settings[:ruby_api])
    puppet_cachedir = File.join(settings[:privatedir], 'puppet', 'ruby')
    gem_wrapper_path = File.join('..', 'ruby_gem_wrapper.bat')

    gem_path_with_puppet_cache = [
      File.join(settings[:privatedir], 'ruby', settings[:ruby_version], 'lib', 'ruby', 'gems', settings[:ruby_api]),
      File.join(puppet_cachedir, settings[:ruby_api]),
    ].join(platform.is_windows? ? ';' : ':')

    if platform.is_windows?
      git_bin = git_bin.gsub(/\/bin\//, '/cmd/').concat('.exe')
      pdk_bin << '.bat'
    end

    mod_name = "vanagon_module_#{settings[:ruby_version].gsub(/[^0-9]/, '')}"

    pre_build_commands = []
    build_commands = []

    # Pre-install some native gems.
    pre_build_commands << "GEM_HOME=#{ruby_cachedir} #{settings[:gem_install]} ../mini_portile2-#{settings[:mini_portile2_version]}.gem"

    if platform.is_windows?
      pre_build_commands << "GEM_HOME=#{ruby_cachedir} #{settings[:gem_install]} ../nokogiri-#{settings[:nokogiri_version]}-x64-mingw32.gem"
    end

    # Clone this component repo to a bare repo inside the project cachedir.
    # Need --no-hardlinks because this is a local clone and hardlinks mess up packaging later.
    build_commands << "#{git_bin} clone --mirror --no-hardlinks . #{File.join(settings[:cachedir], 'pdk-templates.git')}"

    # Use previously installed pdk gem to generate a new module using the
    # cached module template.
    build_commands << "#{pdk_bin} new module #{mod_name} --skip-interview --template-url=file://#{File.join(settings[:cachedir], 'pdk-templates.git')}"

    # Run 'bundle lock' in the generated module and cache the Gemfile.lock
    # inside the project cachedir. We add the private/puppet paths to
    # GEM_PATH to make sure we resolve to a cached version of puppet.
    build_commands << "pushd #{mod_name} && GEM_PATH=\"#{gem_path_with_puppet_cache}\" GEM_HOME=\"#{ruby_cachedir}\" #{settings[:host_bundle]} lock && popd"

    # Copy generated Gemfile.lock into cachedir.
    build_commands << "cp #{mod_name}/Gemfile.lock #{settings[:cachedir]}/Gemfile-#{settings[:ruby_version]}.lock"
    build_commands << "cp #{mod_name}/Gemfile.lock #{settings[:cachedir]}/Gemfile.lock" # legacy support, remove anytime post 1.5.0 release

    # Add some additional gems to support experimental features
    build_commands << "echo 'gem \"puppet-debugger\",                            require: false' >> #{mod_name}/Gemfile"
    build_commands << "echo 'gem \"guard\",                                      require: false' >> #{mod_name}/Gemfile"
    build_commands << "echo 'gem \"listen\",                                     require: false' >> #{mod_name}/Gemfile"
    build_commands << "echo 'gem \"codecov\",                                    require: false' >> #{mod_name}/Gemfile"
    build_commands << "echo 'gem \"license_finder\",                             require: false' >> #{mod_name}/Gemfile"

    # Add some Beaker dependencies for Linux
    unless platform.is_windows?
      build_commands << "echo 'gem \"ruby-ll\", \"2.1.2\",                         require: false' >> #{mod_name}/Gemfile"
      build_commands << "echo 'gem \"byebug\", \"9.0.6\",                          require: false' >> #{mod_name}/Gemfile"
      build_commands << "echo 'gem \"oga\", \"2.15\",                              require: false' >> #{mod_name}/Gemfile"
    end

    # Run 'bundle install' in the generated module to cache the gems
    # inside the project cachedir.
    build_commands << "pushd #{mod_name} && GEM_PATH=\"#{gem_path_with_puppet_cache}\" GEM_HOME=\"#{ruby_cachedir}\" #{settings[:host_bundle]} install && popd"

    # Install bundler into the gem cache
    build_commands << "GEM_HOME=#{ruby_cachedir} #{settings[:host_gem]} install --no-document --local --bindir /tmp ../bundler-#{settings[:bundler_version]}.gem"

    if platform.is_windows?
      # The puppet gem has files in it's 'spec' directory with very long paths which
      # bump up against MAX_PATH on Windows. Since the 'spec' directory is not required
      # at runtime, we just purge it before attempting to package.
      build_commands << "/usr/bin/find #{ruby_cachedir} -regextype posix-extended -regex '.*/puppet-[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+[^/]*/spec/.*' -delete"

      build_commands << "/usr/bin/find #{ruby_cachedir} -name '*.bat' -exec cp #{gem_wrapper_path} {} \\;"
    end

    # Bundle install for each additional ruby version as well, in case we need different versions for a different ruby.
    settings[:additional_rubies]&.each do |rubyver, local_settings|
      local_ruby_cachedir = File.join(settings[:cachedir], 'ruby', local_settings[:ruby_api])

      local_gem_path = [
        File.join(settings[:privatedir], 'ruby', local_settings[:ruby_version], 'lib', 'ruby', 'gems', local_settings[:ruby_api]),
        File.join(puppet_cachedir, local_settings[:ruby_api]),
      ].join(platform.is_windows? ? ';' : ':')

      local_mod_name = "vanagon_module_#{local_settings[:ruby_version].gsub(/[^0-9]/, '')}"

      # Generate a new module for this ruby version.
      build_commands << "#{pdk_bin} new module #{local_mod_name} --skip-interview --template-url=file://#{File.join(settings[:cachedir], 'pdk-templates.git')}"

      # Resolve default gemfile deps
      build_commands << "pushd #{local_mod_name} && PUPPET_GEM_VERSION=\"#{local_settings[:latest_puppet]}\" GEM_PATH=\"#{local_gem_path}\" GEM_HOME=\"#{local_ruby_cachedir}\" #{local_settings[:host_bundle]} install && popd"
      # Update the Gemfile.lock to resolve based on the local gem cache.
      build_commands << "pushd #{local_mod_name} && GEM_PATH=\"#{local_gem_path}\" GEM_HOME=\"#{local_ruby_cachedir}\" #{local_settings[:host_bundle]} lock --local --update && popd"

      build_commands << "mv #{local_mod_name}/Gemfile.lock #{settings[:cachedir]}/Gemfile-#{rubyver}.lock"

      # Add some additional gems to support experimental features
      build_commands << "echo 'gem \"puppet-debugger\",                            require: false' >> #{local_mod_name}/Gemfile"
      build_commands << "echo 'gem \"guard\",                                      require: false' >> #{local_mod_name}/Gemfile"

      # This pin is needed to ensure Ruby 2.1.9 compat still
      build_commands << "echo 'gem \"listen\", \"~> 3.0.8\",                       require: false' >> #{local_mod_name}/Gemfile"

      build_commands << "echo 'gem \"puppet-strings\",                             require: false' >> #{local_mod_name}/Gemfile"
      build_commands << "echo 'gem \"codecov\",                                    require: false' >> #{local_mod_name}/Gemfile"
      build_commands << "echo 'gem \"license_finder\",                             require: false' >> #{local_mod_name}/Gemfile"
      build_commands << "echo 'gem \"nokogiri\", \"<= 1.8.2\",                     require: false' >> #{local_mod_name}/Gemfile"

      # Add some Beaker dependencies for Linux
      unless platform.is_windows?
        build_commands << "echo 'gem \"ruby-ll\", \"2.1.2\",                         require: false' >> #{local_mod_name}/Gemfile"
        build_commands << "echo 'gem \"byebug\", \"9.0.6\",                          require: false' >> #{local_mod_name}/Gemfile"
        build_commands << "echo 'gem \"oga\", \"2.15\",                              require: false' >> #{local_mod_name}/Gemfile"
      end

      # Install all the deps into the package cachedir.
      build_commands << "pushd #{local_mod_name} && PUPPET_GEM_VERSION=\"#{local_settings[:latest_puppet]}\" GEM_PATH=\"#{local_gem_path}\" GEM_HOME=\"#{local_ruby_cachedir}\" #{local_settings[:host_bundle]} install && popd"

      # Install bundler itself into the gem cache for this ruby
      build_commands << "GEM_HOME=#{local_ruby_cachedir} #{local_settings[:host_gem]} install --no-document --local --bindir /tmp ../bundler-#{settings[:bundler_version]}.gem"

      # Prepend native gem installation commands for this ruby
      pre_build_commands << "GEM_HOME=#{local_ruby_cachedir} #{local_settings[:gem_install]} ../mini_portile2-#{settings[:mini_portile2_version]}.gem"

      if platform.is_windows?
        # The puppet gem has files in it's 'spec' directory with very long paths which
        # bump up against MAX_PATH on Windows. Since the 'spec' directory is not required
        # at runtime, we just purge it before attempting to package.
        build_commands << "/usr/bin/find #{local_ruby_cachedir} -regextype posix-extended -regex '.*/puppet-[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+[^/]*/spec/.*' -delete"
        build_commands << "/usr/bin/find #{local_ruby_cachedir} -name '*.bat' -exec cp #{gem_wrapper_path} {} \\;"

        pre_build_commands << "GEM_HOME=#{local_ruby_cachedir} #{local_settings[:gem_install]} ../nokogiri-#{settings[:nokogiri_version]}-x64-mingw32.gem"
      end
    end

    pre_build_commands + build_commands
  end
end
