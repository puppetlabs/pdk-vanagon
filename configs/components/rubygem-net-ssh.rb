component "rubygem-net-ssh" do |pkg, settings, platform|
  pkg.version "4.2.0"
  pkg.md5sum "fec5b151d84110b95ec0056017804491"
  pkg.url "https://rubygems.org/downloads/net-ssh-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment "PATH", settings[:gem_path_env]
  end

  pkg.install do
    "#{settings[:gem_install]} net-ssh-#{pkg.get_version}.gem"
  end
end
