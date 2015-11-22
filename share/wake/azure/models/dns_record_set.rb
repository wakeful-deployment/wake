require 'uri'
require_relative '../model'

module Azure
  class ARecord
    include Model

    required :ip_address

    def to_hash
      {
        ipv4Address: ip_address
      }
    end
  end

  class DNSRecordSet
    include Model

    TYPES = {
      "A" => ARecord
    }.freeze

    parent   :dns_zone
    required :name
    optional :type,    default: "A"
    optional :ttl,     default: 60
    optional :records, default: ->{[]}

    def add_record(**info)
      if Hash === info
        info = TYPES[type].new(**info)
      end

      @records.push info
    end

    def location
      "global"
    end

    uri { URI("#{dns_zone.uri}/#{type}/#{name}") }
  end
end
