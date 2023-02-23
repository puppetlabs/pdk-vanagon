component "pdk-templates" do |pkg, settings, platform|
  # Set url and ref from json file so it's easy for jenkins
  # to promote new template versions.
  pkg.load_from_json('configs/components/pdk-templates.json')

  pkg.build_requires "pdk-runtime"
  pkg.build_requires "rubygem-bundler"
  pkg.build_requires "rubygem-pdk"
  pkg.build_requires "puppet-versions"

  # pkg.add_source("file://resources/patches/bundler-relative-rubyopt.patch")

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
    pkg.add_source "https://rubygems.org/downloads/unf_ext-0.0.7.7-x64-mingw32.gem", sum: '218e85fd56b9ecd5618cc20a76f45601'
  elsif platform.is_linux? && settings[:use_pl_build_tools]
    pkg.build_requires "pl-gcc"
    pkg.environment "PATH", "/opt/pl-build-tools/bin:$(PATH)"
  end

  pkg.build do
    git_bin_path = File.join(settings[:privatedir], 'git', 'bin')
    git_bin = File.join(git_bin_path, 'git')
    pdk_bin = File.join(settings[:ruby_bindir], 'pdk')
    ruby_cachedir = File.join(settings[:cachedir], 'ruby', settings[:ruby_api])
    puppet_cachedir = File.join(settings[:privatedir], 'puppet', 'ruby')

    # Work is needed here. This should account for the presence of the SHA or version.
    template_ref = pkg.get_version == 'unknown' || pkg.get_version.nil? ? 'main' : pkg.get_version

    gem_path_with_puppet_cache = [
      File.join(settings[:privatedir], 'ruby', settings[:ruby_version], 'lib', 'ruby', 'gems', settings[:ruby_api]),
      File.join(puppet_cachedir, settings[:ruby_api]),
    ].join(platform.is_windows? ? ';' : ':')

    if platform.is_windows?
      git_bin = git_bin.gsub(/\/bin\//, '/cmd/').concat('.exe')
      pdk_bin << '.bat'
    end

    gem_env = [
      "GEM_PATH=\"#{gem_path_with_puppet_cache}\"",
      "GEM_HOME=\"#{ruby_cachedir}\"",
    ]

    gem_env << "PUPPET_GEM_VERSION=\"#{settings[:latest_puppet]}\"" if settings[:latest_puppet]

    mod_name = "vanagon_module_#{settings[:ruby_version].gsub(/[^0-9]/, '')}"

    pre_build_commands = []
    build_commands = []

    # Clone this component repo to a bare repo inside the project cachedir.
    # Need --no-hardlinks because this is a local clone and hardlinks mess up packaging later.
    build_commands << "#{git_bin} clone --mirror --no-hardlinks . #{File.join(settings[:cachedir], 'pdk-templates.git')}"

    # Use previously installed pdk gem to generate a new module using the
    # cached module template.
    build_commands << "#{pdk_bin} new module #{mod_name} --skip-interview --template-ref=#{template_ref} --template-url=file:///#{File.join(settings[:cachedir], 'pdk-templates.git')} --skip-bundle-install"

    # Run 'bundle lock' in the generated module and cache the Gemfile.lock
    # inside the project cachedir. We add the private/puppet paths to
    # GEM_PATH to make sure we resolve to a cached version of puppet.
    build_commands << "pushd #{mod_name} && #{gem_env.join(' ')} #{settings[:host_bundle]} lock && popd"

    # Copy generated Gemfile.lock into cachedir.
    build_commands << "cp #{mod_name}/Gemfile.lock #{settings[:cachedir]}/Gemfile-#{settings[:ruby_version]}.lock"
    build_commands << "cp #{mod_name}/Gemfile.lock #{settings[:cachedir]}/Gemfile.lock"

    # Add some additional gems to support experimental features
    # build_commands << "echo 'gem \"puppet-debugger\",                            require: false' >> #{mod_name}/Gemfile"
    build_commands << "echo 'gem \"guard\",                                      require: false' >> #{mod_name}/Gemfile"
    build_commands << "echo 'gem \"listen\",                                     require: false' >> #{mod_name}/Gemfile"
    # build_commands << "echo 'gem \"codecov\",                                    require: false' >> #{mod_name}/Gemfile"
    build_commands << "echo 'gem \"license_finder\",                             require: false' >> #{mod_name}/Gemfile"

    # Add some Beaker dependencies for Linux
    unless platform.is_windows?
      build_commands << "echo 'gem \"ruby-ll\", \"2.1.2\",                         require: false' >> #{mod_name}/Gemfile"
      build_commands << "echo 'gem \"oga\", \"2.15\",                              require: false' >> #{mod_name}/Gemfile"
    end

    # Run 'bundle install' in the generated module to cache the gems
    # inside the project cachedir.
    build_commands << "pushd #{mod_name} && #{gem_env.join(' ')} #{settings[:host_bundle]} install && popd"

    unless platform.is_windows?
      settings[:byebug_version][settings[:ruby_api]].each do |byebug_version|
        build_commands << "#{gem_env.join(' ')} #{settings[:host_gem]} install --no-document byebug:#{byebug_version}"
      end
    end

    # Install bundler into the gem cache
    build_commands << "#{gem_env.join(' ')} #{settings[:host_gem]} install --no-document --local --bindir /tmp ../bundler-#{settings[:bundler][:version]}.gem"

    if platform.is_windows?
      # The puppet gem has files in it's 'spec' directory with very long paths which
      # bump up against MAX_PATH on Windows. Since the 'spec' directory is not required
      # at runtime, we just purge it before attempting to package.
      build_commands << "/usr/bin/find #{ruby_cachedir} -regextype posix-extended -regex '.*/puppet-[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+[^/]*/spec/.*' -delete"
    end

    # Bundle install for each additional ruby version as well, in case we need different versions for a different ruby.
    settings[:additional_rubies]&.each do |rubyver, local_settings|
      local_ruby_cachedir = File.join(settings[:cachedir], 'ruby', local_settings[:ruby_api])

      local_gem_path = [
        File.join(settings[:privatedir], 'ruby', local_settings[:ruby_version], 'lib', 'ruby', 'gems', local_settings[:ruby_api]),
        File.join(puppet_cachedir, local_settings[:ruby_api]),
      ].join(platform.is_windows? ? ';' : ':')

      local_gem_env = [
        "GEM_PATH=\"#{local_gem_path}\"",
        "GEM_HOME=\"#{local_ruby_cachedir}\"",
      ]


      local_gem_env << "PUPPET_GEM_VERSION=\"#{local_settings[:latest_puppet]}\"" if local_settings[:latest_puppet]

      local_mod_name = "vanagon_module_#{local_settings[:ruby_version].gsub(/[^0-9]/, '')}"

      # Generate a new module for this ruby version.
      build_commands << "#{pdk_bin} new module #{local_mod_name} --skip-interview --template-ref=#{template_ref} --template-url=file:///#{File.join(settings[:cachedir], 'pdk-templates.git')} --skip-bundle-install"

      # Resolve default gemfile deps
      build_commands << "pushd #{local_mod_name} && #{local_gem_env.join(' ')} #{local_settings[:host_bundle]} update && popd"

      build_commands << "mv #{local_mod_name}/Gemfile.lock #{settings[:cachedir]}/Gemfile-#{rubyver}.lock"

      # Add some additional gems to support experimental features
      build_commands << "echo 'gem \"guard\",                                      require: false' >> #{local_mod_name}/Gemfile"

      build_commands << "echo 'gem \"puppet-strings\",                             require: false' >> #{local_mod_name}/Gemfile"
      build_commands << "echo 'gem \"license_finder\",                             require: false' >> #{local_mod_name}/Gemfile"

      # Add some Beaker dependencies for Linux
      unless platform.is_windows?
        build_commands << "echo 'gem \"ruby-ll\", \"2.1.2\",                         require: false' >> #{local_mod_name}/Gemfile"
        build_commands << "echo 'gem \"oga\", \"2.15\",                              require: false' >> #{local_mod_name}/Gemfile"
      end

      # Install all the deps into the package cachedir.
      build_commands << "pushd #{local_mod_name} && #{local_gem_env.join(' ')} #{local_settings[:host_bundle]} install && popd"

      unless platform.is_windows?
        settings[:byebug_version][local_settings[:ruby_api]].each do |byebug_version|
          build_commands << "#{local_gem_env.join(' ')} #{local_settings[:host_gem]} install --no-document byebug:#{byebug_version}"
        end
      end

      # Install bundler itself into the gem cache for this ruby
      build_commands << "#{local_gem_env.join(' ')} #{local_settings[:host_gem]} install --no-document --local --bindir /tmp ../bundler-#{settings[:bundler][:version]}.gem"

      if platform.is_windows?
        # The puppet gem has files in it's 'spec' directory with very long paths which
        # bump up against MAX_PATH on Windows. Since the 'spec' directory is not required
        # at runtime, we just purge it before attempting to package.
        build_commands << "/usr/bin/find #{local_ruby_cachedir} -regextype posix-extended -regex '.*/puppet-[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+[^/]*/spec/.*' -delete"

        unless local_settings[:ruby_api].start_with?('2.1.')
          pre_build_commands << "#{local_gem_env.join(' ')} #{local_settings[:gem_install]} ../unf_ext-0.0.7.7-x64-mingw32.gem"
        end
      end
    end

    # Patch bundler RUBYOPT config so that it doesn't explode on paths that include spaces
    # abort "Check if set_rubyopt patch is still needed for this bundler version!" if settings[:bundler_version] != '2.1.4'
    # build_commands << "/usr/bin/find #{settings[:prefix]} -path \"*/bundler-2.1.4/lib/bundler/shared_helpers.rb\" -print0 | xargs -0 -n 1 -I {} patch {} ../bundler-relative-rubyopt.patch"
    # build_commands << "/usr/bin/find #{settings[:prefix]} -path \"*/bundler-2.1.4/lib/bundler/shared_helpers.rb.orig\" -delete"

    # Fix permissions
    chmod_changes_flag = platform.is_macos? ? "-vv" : "--changes"
    build_commands << "chmod -R #{chmod_changes_flag} ugo+rX #{File.join(settings[:cachedir], 'ruby')} #{File.join(settings[:privatedir], 'puppet', 'ruby')} #{File.join(settings[:privatedir], 'ruby')}"

    pre_build_commands + build_commands
  end
end
