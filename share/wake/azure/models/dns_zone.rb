require 'uri'
require_relative '../model'

module Azure
  class DNSZone
    include Model

    parent   :resource_group
    required :name

    def location
      "global"
    end

    uri { URI("#{resource_group.uri}/providers/Microsoft.Network/dnszones/#{name}") }
  end
end
