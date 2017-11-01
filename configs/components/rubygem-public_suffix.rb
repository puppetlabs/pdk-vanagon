component "rubygem-public_suffix" do |pkg, settings, platform|
  pkg.version "3.0.0"
  pkg.md5sum "787a298cfb1e4d9f39aa43a415d53e6f"
  pkg.url "#{settings[:buildsources_url]}/public_suffix-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} public_suffix-#{pkg.get_version}.gem"
  end
end
