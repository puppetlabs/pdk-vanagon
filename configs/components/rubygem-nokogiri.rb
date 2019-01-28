component 'rubygem-nokogiri' do |pkg, settings, platform|
  gemname = pkg.get_name.gsub('rubygem-', '')
  pkg.version settings[:nokogiri_version]
  pkg.md5sum "a8ee8d3da2a686dd27bd9c2786eb2216"
  pkg.url "http://rubygems.org/downloads/#{gemname}-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"
  pkg.build_requires 'rubygem-mini_portile2'

  if platform.is_windows?
    pkg.environment 'PATH', settings[:gem_path_env]
    pkg.url "#{settings[:buildsources_url]}/#{gemname}-#{pkg.get_version}-x64-mingw32.gem"
    pkg.md5sum "2e7c07baa7db36b31f33d5a0656db649"

    pkg.install do
      ["#{settings[:gem_install]} #{gemname}-#{pkg.get_version}-x64-mingw32.gem"]
    end
    pkg.build_requires "pl-zlib-#{platform.architecture}"
  else
    pkg.build_requires 'cmake'

    if platform.is_rpm?
      # red hat
      pkg.build_requires 'pkgconfig'
    else
      # debian
      pkg.build_requires 'pkg-config'
    end

    if platform.is_deb?
      pkg.build_requires "zlib1g-dev"
    elsif platform.is_aix?
      pkg.build_requires "http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/zlib-devel-1.2.3-4.aix5.2.ppc.rpm"
    elsif platform.is_rpm?
      pkg.build_requires "zlib-devel"
    end

    pkg.install do
      ["#{settings[:gem_install]} #{gemname}-#{pkg.get_version}.gem"]
    end
  end
end
