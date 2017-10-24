component 'rubygem-nokogiri' do |pkg, settings, platform|
  gemname = pkg.get_name.gsub('rubygem-', '')
  pkg.version settings[:nokogiri_version]
  pkg.md5sum "65eab96f98f22763766efe663d102cf3"
  pkg.url "http://rubygems.org/downloads/#{gemname}-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"
  pkg.build_requires 'rubygem-mini_portile2'

  if platform.is_windows?
    pkg.environment 'PATH', settings[:gem_path_env]
    pkg.url "https://buildsources.delivery.puppetlabs.net/#{gemname}-#{pkg.get_version}-x64-mingw32.gem"
    pkg.md5sum "fdcb75a394aa944dec24fdd8c183d741"

    pkg.install do
      ["#{settings[:gem_install]} #{gemname}-#{pkg.get_version}-x64-mingw32.gem"]
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

    pkg.install do
      [
        "PKG_CONFIG_PATH='#{settings[:pkg_config_path]}' \
        CFLAGS='#{settings[:cflags]}' \
        LDFLAGS='#{settings[:ldflags]}' \
        CC=/opt/pl-build-tools/bin/gcc \
        #{settings[:gem_install]} #{gemname}-#{pkg.get_version}.gem -- --with-opt-dir=#{settings[:prefix]} --use-system-libraries"
      ]
    end
  end
end
