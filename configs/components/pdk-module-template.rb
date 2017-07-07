component "rubygem-pdk" do |pkg, settings, platform|
  # Set url and ref from json file so it's easy for jenkins
  # to promote new template versions.
  pkg.load_from_json('configs/components/pdk-module-template.json')

  pkg.build_requires "git"
  pkg.build_requires "ruby-#{settings[:ruby_version]}"
  pkg.build_requires "rubygem-bundler"
  pkg.build_requires "rubygem-pdk"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  else
    pkg.build_requires "pl-gcc" if platform.is_linux?

    pkg.environment "PATH", "/opt/pl-build-tools/bin:$(PATH)"
  end

  pkg.build do
    git_bin = File.join(settings[:privatedir], 'git', 'bin', 'git')
    pdk_bin = File.join(settings[:ruby_bindir], 'pdk')
    bundle_bin = File.join(settings[:ruby_bindir], 'bundle')

    if platform.is_windows?
      git_bin = git_bin.gsub(/\/bin\//, '/cmd/').concat('.exe')
      pdk_bin << '.bat'
      bundle_bin << '.bat'
    end

    build_commands = [
      # Clone this component repo to a bare repo inside the project cachedir.
      # Need --no-hardlinks because this is a local clone and hardlinks mess up packaging later.
      "#{git_bin} clone --bare --no-hardlinks . #{File.join(settings[:cachedir], 'pdk-module-template.git')}",

      # Use previously installed pdk gem to generate a new module using the
      # cached module template.
      "#{pdk_bin} new module vanagon_module --skip-interview --template-url=file://#{File.join(settings[:cachedir], 'pdk-module-template.git')}",

      # Run 'bundle install' in the generated module and cache the gems
      # inside the project cachedir.
      # TODO: consider using --deployment flag?
      "cd vanagon_module && #{bundle_bin} install --path #{settings[:cachedir]}",
    ]

    if platform.is_windows?
      # The puppet gem has files in it's 'spec' directory with very long paths which
      # bump up against MAX_PATH on Windows. Since the 'spec' directory is not required
      # at runtime, we just purge it before attempting to package.
      build_commands << "/usr/bin/find #{File.join(settings[:cachedir], 'ruby')} -regextype posix-extended -regex '.*/puppet-[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+[^/]*/spec/.*' -delete"
    end

    build_commands
  end
end
