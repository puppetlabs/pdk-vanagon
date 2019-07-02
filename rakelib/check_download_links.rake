require 'net/http'
require 'net/https'
require 'uri'

desc "Check that PDK download links point to the correct version"
task :check_download_links, [:version] do |_task, args|
  version = args[:version] || `git describe --abbrev=0`
  puts "Checking that PDK download links point to #{version}"
  DownloadLinkCheck.new.check_latest(version)
end

class DownloadLinkCheck
  HOST='pm.puppet.com'

  def check_latest(expected_version)
    failure = false

    platforms.each do |platform|
      dist, rel, arch = platform.split('-')
      dist = 'win' if dist == 'windows'
      params = [
        "dist=#{dist}",
        "rel=#{rel}",
        "arch=#{arch}",
        "ver=latest",
      ]

      print "#{platform} => "
      begin
        download_url = request("https://#{HOST}/cgi-bin/pdk_download.cgi?#{params.join('&')}")
        if download_url.include?(expected_version)
          puts "OK"
        else
          puts "Incorrect version! #{download_url}"
          failure = true
        end
      rescue ArgumentError => e
        failure = true
        puts e.message
      end
    end

    abort if failure
  end

  def platforms
    platform_dir = File.expand_path(File.join(__dir__, '..', 'configs', 'platforms'))
    Dir.glob(File.join(platform_dir, '*.rb')).map { |r| File.basename(r, '.rb') }.sort
  end

  def request(url, limit=5)
    raise ArgumentError, 'HTTP request too deep' if limit.zero?

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    response = http.head(uri.request_uri)

    case response
    when Net::HTTPSuccess
      url
    when Net::HTTPRedirection
      request(response['location'], limit - 1)
    else
      raise ArgumentError, "#{response.code} (#{response.message}): #{url}"
    end
  end
end
