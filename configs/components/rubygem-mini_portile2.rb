component 'rubygem-mini_portile2' do |pkg, settings, platform|
  pkg.version settings[:mini_portile2_version]['default'][:version]
  pkg.md5sum settings[:mini_portile2_version]['default'][:checksum]
  pkg.url "#{settings[:buildsources_url]}/mini_portile2-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"

  if platform.is_windows?
    pkg.environment 'PATH', settings[:gem_path_env]
  end

  pkg.install do
    # For Ruby versions > 2.4.0 of this component we only need
    # vanagon to stage the .gem, not install anything. The gem will
    # actually be installed in the pdk-templates component.
    "echo no-op"
  end
end
