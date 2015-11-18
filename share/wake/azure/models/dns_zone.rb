require 'uri'
require_relative '../model'

module Azure
  class DNSZone
    include SubResource

    parent :resource_group

    uri { URI("#{resource_group.uri}/providers/Microsoft.Network/dnszones/#{name}") }
  end
end
