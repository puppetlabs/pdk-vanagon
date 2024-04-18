source ENV['GEM_SOURCE'] || "https://rubygems.org"

def location_for(place)
  if place =~ /^(git[:@][^#]*)#(.*)/
    [{ :git => $1, :branch => $2, :require => false }]
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end

gem 'vanagon', *location_for(ENV['VANAGON_LOCATION'] || '~> 0.48.0')
gem 'packaging', *location_for(ENV['PACKAGING_LOCATION'] || '>= 0.118.0')

# csv > 3.1.5 requires 'stringio' which the latest version of requires Ruby >= 2.5.0
gem 'csv', '3.1.5' if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.5.0')

gem 'rake'

gem 'gems' # Rubygems API

#gem 'rubocop', "~> 0.34.2"
group :ci do
  # in the ci pipeline, we calculate required ressources for TEST_TARGETS with bhg
  gem 'beaker-hostgenerator', '~> 2.11'
end
