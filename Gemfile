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

gem 'vanagon', *location_for(ENV['VANAGON_LOCATION'] || '~> 0.15.38')
gem 'packaging', *location_for(ENV['PACKAGING_LOCATION'] || '0.99.66')
gem 'rake', '~> 12.0'

#gem 'rubocop', "~> 0.34.2"
