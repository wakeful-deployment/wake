require_relative '../resources'

module Azure
  setup_resources do
    resources :vnets do
      version "2015-06-15"
      action :get
      action :delete
      action :put do
        def body
          {
            location: model.location,
            properties: {
              addressSpace: {
                addressPrefixes: [model.address_prefix]
              }
            }
          }
        end
      end
    end
  end
end

