component "rubygem-hitimes" do |pkg, settings, platform|
  gemname = 'hitimes'
  pkg.version "2.0.0"
  pkg.md5sum "5ca6bf1112e126de0f6e2a39231dc281"
  pkg.url "#{settings[:buildsources_url]}/hitimes-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
     pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} hitimes-#{pkg.get_version}.gem"
  end
end
