require_relative '../resources'

module Azure
  setup_resources do
    resources :subscriptions do
      version "2014-04-01-preview"
      action :get
    end
  end
end
