require 'net/http'
require 'json'
require 'resolv'
require 'pp'
require 'cgi'

def url_get(srv_records)

  targets = Array.new

  srv_records.collect do |resource|

    url = "https://#{resource.target}:#{resource.port}/api/ping"
    uri = URI(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
    res = http.get(uri.request_uri)

    #puts res.body if res.is_a?(Net::HTTPSuccess)

    if res.body == "OK"
      targets.push("#{resource.target}:#{resource.port}")
      #target = resource.target
      #return target
      #break
    end
  end

  return targets.sample

end

def conf_get(target,token,configuration,environment)

  base_url = "https://#{target}/api"
  #puts "BASE URL: " + base_url

  full_url = "#{base_url}/configurations/#{configuration}?format=json&displayValues=true"
  #puts full_url
  url = URI.parse(full_url)
  req = Net::HTTP::Get.new(url)
  req.add_field("Authorization", "GCCAPPK:#{token}")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?

  res = http.start do |http|

    http.request(req)
  end

  #puts res.body

  response = JSON.parse(res.body)
  return response['values'][environment]

end

def pwd_get(target,token,credential,environment)

  base_url = "https://#{target}/api"
  #puts "BASE URL: " + base_url

  full_url = "#{base_url}/credentials/#{credential}?format=json&displayValues=true"
  #puts full_url
  url = URI.parse(full_url)
  req = Net::HTTP::Get.new(url)
  req.add_field("Authorization", "GCCAPPK:#{token}")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?

  res = http.start do |http|

    http.request(req)
  end

  #puts res.body

  response = JSON.parse(res.body)
  return response['values'][environment]

end
