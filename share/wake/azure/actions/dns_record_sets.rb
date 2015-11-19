require_relative '../resources'

module Azure
  setup_resources do
    resources :dns_record_sets do
      version "2015-05-04-preview"
      action :get
      action :put do
        def records
          if model.type == "A"
            { ARecords: model.records.map(&:to_hash) }
          else
            fail "We only support A records right now"
          end
        end

        def properties
          { TTL: model.ttl }.merge(records)
        end

        def body
          {
            location: model.location,
            properties: properties
          }
        end
      end
    end
  end
end
