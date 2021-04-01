component "rubygem-bundler" do |pkg, settings, platform|
  pkg.version settings[:bundler_version]
  pkg.md5sum "5846a691720faeca26f49111f9a1862e"
  pkg.url "#{settings[:buildsources_url]}/bundler-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    install_commands = ["#{settings[:gem_install]} bundler-#{pkg.get_version}.gem"]

    settings[:additional_rubies].each do |rubyver, local_settings|
      install_commands << "#{local_settings[:gem_install]} bundler-#{pkg.get_version}.gem"
    end

    install_commands
  end
end
