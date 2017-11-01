component "rubygem-tty-which" do |pkg, settings, platform|
  pkg.version "0.3.0"
  pkg.md5sum "633a1f4f8c6e15a26cb83e1be0b9f2ce"
  pkg.url "#{settings[:buildsources_url]}/tty-which-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} tty-which-#{pkg.get_version}.gem"
  end
end
