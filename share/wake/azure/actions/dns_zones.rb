require_relative '../resources'

module Azure
  setup_resources do
    resources :dns_zones do
      version "2015-05-04-preview"
      action :record_sets, verb: :get, path: "/recordsets"
      action :get
      action :put do
        def body
          {
            location: model.location,
            properties: {
            }
          }
        end
      end
    end
  end
end
