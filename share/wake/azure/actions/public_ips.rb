require_relative '../resources'

module Azure
  setup_resources do
    resources :public_ips do
      version "2015-06-15"
      action :get
      action :delete
      action :put do
        def body
          {
            location: model.location,
            properties: {
              publicIPAllocationMethod: "Dynamic",
              dnsSettings: {
                domainNameLabel: "#{model.name}-#{model.resource_group.name}"
              }
            }
          }
        end
      end
    end
  end
end

