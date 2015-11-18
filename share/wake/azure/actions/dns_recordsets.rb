require_relative '../resources'

module Azure
  setup_resources do
    resources :dns_recordsets do
      version "2015-05-04-preview"
      action :get
      action :put do
        def a_records
          model.records["A"].map do |r|
            {
              ipv4Address: r.ip_address
            }
          end
        end

        def aaaa_records
          model.records["AAAA"].map do |r|
            {
              ipv6Address: r.ip_address
            }
          end
        end

        def cname_records
          model.records["CNAME"].map do |r|
            {
              cname: r.name
            }
          end
        end

        def mx_records
          model.records["MX"].map do |r|
            {
              preference: r.preference,
              exchange:   r.exchange
            }
          end
        end

        def ns_records
          model.records["NS"].map do |r|
            {
              nsdname: r.name
            }
          end
        end

        def prt_records
          model.records["PTR"].map do |r|
            {
              ptrdname: r.name
            }
          end
        end

        def soa_records
          model.records["SOA"].map do |r|
            {
              host:         r.host,
              email:        r.email,
              serialNumber: r.serial_number,
              refreshTime:  r.refresh_time,
              retryTime:    r.refresh_time,
              expireTime:   r.expire_time,
              minimumTTL:   r.minimum_ttl
            }
          end
        end

        def srv_records
          model.records["SRV"].map do |r|
            {
              priority: r.priority,
              weight:   r.weight,
              port:     r.port,
              target:   r.target
            }
          end
        end

        def txt_records
          model.records["TXT"].map do |r|
            {
              value: r.value
            }
          end
        end

        def body
          {
            location: model.location,
            properties: {
              TTL: model.ttl,
              AAAARecords: aaaa_records,
              ARecords: a_records,
              CNAMERecord: cname_records,
              MXRecords: mx_records,
              NSRecords: ns_records,
              PTRRecords: ptr_records,
              SOARecord: soa_records,
              SRVRecords: srv_records,
              TXTRecords: txt_records,
            }
          }
        end
      end
    end
  end
end
