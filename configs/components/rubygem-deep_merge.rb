component "rubygem-deep_merge" do |pkg, settings, platform|
  pkg.version "1.1.1"
  pkg.md5sum "1b2527fa722b54bf0406fd7ab6cc5e08"
  pkg.url "#{settings[:buildsources_url]}/deep_merge-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} deep_merge-#{pkg.get_version}.gem"
  end
end
