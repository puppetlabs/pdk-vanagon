component 'pdk-templates' do |pkg, settings, platform|
  # Set url and ref from json file so it's easy for jenkins
  # to promote new template versions.
  pkg.load_from_json('configs/components/pdk-templates.json')

  pkg.build_requires 'pdk-runtime'
  pkg.build_requires 'rubygem-bundler'
  pkg.build_requires 'rubygem-pdk'
  pkg.build_requires 'puppet-versions'
  pkg.add_source('file://resources/patches/bundler-relative-rubyopt.patch')

  if platform.is_windows?
    pkg.environment 'PATH', settings[:gem_path_env]
    pkg.add_source 'https://rubygems.org/downloads/unf_ext-0.0.7.7-x64-mingw32.gem', sum: '218e85fd56b9ecd5618cc20a76f45601'
  elsif platform.is_linux? && settings[:use_pl_build_tools]
    pkg.build_requires 'pl-gcc'
    pkg.environment 'PATH', '/opt/pl-build-tools/bin:$(PATH)'
  end

  pkg.build do
    instance_eval File.read('configs/components/_template_helper.rb')

    pre_build_commands = []
    build_commands = []

    # Work is needed here. This should account for the presence of the SHA or version.
    template_ref = pkg.get_version == 'unknown' || pkg.get_version.nil? ? 'main' : pkg.get_version

    git_bin_path = File.join(settings[:privatedir], 'git', 'bin')
    git_bin = File.join(git_bin_path, 'git')
    git_bin = git_bin.gsub(/\/bin\//, '/cmd/').concat('.exe') if platform.is_windows?

    pdk_bin = File.join(settings[:ruby_bindir], 'pdk')
    pdk_bin << '.bat' if platform.is_windows?

    # Clone this component repo to a bare repo inside the project cachedir.
    # Need --no-hardlinks because this is a local clone and hardlinks mess up packaging later.
    build_commands << "#{git_bin} clone --mirror --no-hardlinks . #{File.join(settings[:cachedir], 'pdk-templates.git')}"

    # Build module for each ruby version and create our gem cache.
    build_commands << build_module(settings, pdk_bin ,settings[:cachedir], settings[:privatedir], template_ref, platform.is_windows?)

    settings[:additional_rubies]&.each do |_rubyver, local_settings|
      build_commands << build_module(local_settings, pdk_bin, settings[:cachedir], settings[:privatedir], template_ref, platform.is_windows?)
    end

    # Patch bundler RUBYOPT config so that it doesn't explode on paths that include spaces
    # This still appears to be an issue as of bundler 2.3.26
    build_commands << "/usr/bin/find #{settings[:prefix]} -path \"*/bundler*/lib/bundler/shared_helpers.rb\" -print0 | xargs -0 -n 1 -I {} patch {} ../bundler-relative-rubyopt.patch"
    build_commands << "/usr/bin/find #{settings[:prefix]} -path \"*/bundler*/lib/bundler/shared_helpers.rb.orig\" -delete"

    # Fix permissions
    chmod_changes_flag = platform.is_macos? ? '-vv' : '--changes'
    build_commands << "chmod -R #{chmod_changes_flag} ugo+rX #{File.join(settings[:cachedir], 'ruby')} #{File.join(settings[:privatedir], 'puppet', 'ruby')} #{File.join(settings[:privatedir], 'ruby')}"

    pre_build_commands + build_commands
  end
end
