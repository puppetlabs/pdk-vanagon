component 'gem-prune' do |pkg, settings, platform|
  pkg.build_requires 'pdk-runtime'
  pkg.build_requires 'pdk-templates'
  pkg.build_requires 'puppet-forge-api'

  pkg.add_source('file://resources/rubygems-prune')

  pkg.build do
    puppet_cachedir = File.join(settings[:privatedir], 'puppet', 'ruby')
    ruby_cachedir = File.join(settings[:cachedir], 'ruby')

    gem_bins = {
      settings[:ruby_api] => settings[:host_gem],
    }

    settings[:additional_rubies]&.each do |rubyver, local_settings|
      gem_bins[local_settings[:ruby_api]] = local_settings[:host_gem]
    end

    pdk_ruby_versions = ['2.1.0', '2.4.0', '2.5.0']

    pdk_ruby_versions.map do |rubyapi|
      "GEM_PATH=#{File.join(puppet_cachedir, rubyapi)}:#{File.join(ruby_cachedir, rubyapi)} RUBYOPT=-Irubygems-prune #{gem_bins[rubyapi]} prune"
    end
  end
end
