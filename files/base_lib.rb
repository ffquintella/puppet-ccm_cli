require 'net/http'
require 'json'
require 'resolv'
require 'pp'
require 'cgi'


# Ruby http read base libs

def dns_get(srv_record)
  resolver = Resolv::DNS.new
  return hosts = resolver.getresources(srv_record, Resolv::DNS::Resource::IN::SRV)
end
