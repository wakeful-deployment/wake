require 'uri'
require_relative '../models'
require_relative 'dns_recordtypes.rb'

module Azure
  class DNSRecordset
    include SubResource
    include DNSRecordTypes

    HASH_OF_ARRAYS = Hash.new do |h, k|
      h[k] = []
    end

    parent   :dns_zone
    required :type
    optional :records, default: HASH_OF_ARRAYS
    optional :ttl,     default: 60

    private def prepare_record(type = nil, info)
      if type.nil?
        type, _ = info.find { |k,v| v === info }
      else
        if HASH === info
          klass = TYPES[type]
          info = klass.new(**info)
        end
      end

      [type, info]
    end

    def add_record(type = nil, info)
      type, info = prepare_record(type, info)
      records[type] << info unless records[type].include? info
    end

    def delete_record(type = nil, info)
      type, info = prepare_record(type, info)
      records[type].delete_if { |r| r == info }
    end

    uri { URI("#{dns_zone.uri}/#{type}/#{name}") }
  end
end
