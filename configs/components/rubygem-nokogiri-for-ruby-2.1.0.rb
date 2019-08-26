component 'rubygem-nokogiri-for-ruby-2.1.0' do |pkg, settings, platform|
  gemname = 'nokogiri'

  # We don't know exactly what Ruby API PDK is built against so just use the 'default'
  # See /configs/projects/pdk.rb for the actual version used:  `proj.setting(:nokogiri_version) = ...`
  pkg.version settings[:nokogiri_version]['2.1.0'][:version]
  pkg.md5sum settings[:nokogiri_version]['2.1.0'][:posix_checksum]

  pkg.url "http://rubygems.org/downloads/#{gemname}-#{pkg.get_version}.gem"

  pkg.build_requires "pdk-runtime"
  pkg.build_requires 'rubygem-mini_portile2-for-ruby-2.1.0'

  if platform.is_windows?
    pkg.environment 'PATH', settings[:gem_path_env]
    pkg.url "#{settings[:buildsources_url]}/#{gemname}-#{pkg.get_version}-x64-mingw32.gem"
    pkg.md5sum settings[:nokogiri_version]['2.1.0'][:win_checksum]

    pkg.build_requires "pl-zlib-#{platform.architecture}"

    pkg.install do
      # For the Ruby 2.1.x version of this component we only need
      # vanagon to stage the .gem, not install anything. The gem will
      # actually be installed in the pdk-templates component.
      "echo no-op"
    end
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
      # For the Ruby 2.1.x version of this component we only need
      # vanagon to stage the .gem, not install anything. The gem will
      # actually be installed in the pdk-templates component.
      "echo no-op"
    end
  end
end
