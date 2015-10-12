require_relative '../resources'

module Azure
  setup_resources do
    resources :resource_groups do
      version "2014-04-01-preview"
      action :get
      action :delete
      action :put do
        def body
          {
            location: model.location
          }
        end
      end
    end
  end
end

