require_relative '../resources'

module Azure
  setup_resources do
    resources :storage_accounts do
      version "2015-06-15"
      action :get
      action :delete
      action :put do
        def body
          {
            location: model.location,
            properties: {
              accountType: "Standard_LRS"
            }
          }
        end
      end
    end
  end
end

