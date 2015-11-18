require_relative '../model'

module Azure
  module DNSRecordTypes
    class ARecord
      include Model
      required :ip_address
    end

    class AAAARecord
      include Model
      required :ip_address
    end

    class CNAMERecord
      include Model
      required :name
    end

    class MXRecord
      include Model
      required :exchange
      optional :preference, default: 0
    end

    class NSRecord
      include Model
      required :name
    end

    class PTRRecord
      include Model
      required :name
    end

    class SOARecord
      include Model
      required :host
      required :email
      required :serial_number
      required :refresh_time
      required :retry_time
      required :expire_time
      required :minimum_ttl
    end

    class SRVRecord
      include Model
      required :port
      required :target
      optional :priority, default: 0
      optional :weight,   default: 5
    end

    class TXTRecord
      include Model
      optional :value, default: []
    end

    TYPES = {
      "A"     => ARecord,
      "AAAA"  => AAAARecord,
      "CNAME" => CNAMERecord,
      "MX"    => MXRecord,
      "NS"    => NSRecord,
      "PTR"   => PTRRecord,
      "SOA"   => SOARecord,
      "SRV"   => SRVRecord,
      "TXT"   => TXTRecord
    }.freeze
  end
end
