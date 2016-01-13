require_relative '../resources'

module Azure
  setup_resources do
    resources :nics do
      version "2015-06-15"
      action :get
      action :delete
      action :put do
        def has_public_ip?
          !!model.public_ip
        end

        def public_ip_address
          {
            id: model.public_ip.uri
          }
        end

        def subnet
          {
            id: model.subnet.uri
          }
        end

        def ip_configuration
          {
            name: "#{model.name}-ip-config",
            properties: {
              privateIPAllocationMethod: "Dynamic",
              subnet: subnet
            }.tap do |prop|
              if has_public_ip?
                prop.merge!(publicIPAddress: public_ip_address)
              end
            end
          }
        end

        def body
          {
            location: model.location,
            properties: {
              ipConfigurations: [ip_configuration]
            }
          }
        end
      end
    end
  end
end
