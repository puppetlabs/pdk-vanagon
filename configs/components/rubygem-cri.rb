component "rubygem-cri" do |pkg, settings, platform|
  pkg.version "2.9.1"
  pkg.md5sum "a69b95364558623133d15ad25a7be46a"
  pkg.url "#{settings[:buildsources_url]}/cri-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} cri-#{pkg.get_version}.gem"
  end
end
