require_relative '../resources'

module Azure
  setup_resources do
    resources :extensions do
      version "2015-06-15"
      action :get
      action :put do
        def body
          {
            location: model.location,
            properties: {
              publisher: model.publisher,
              type: model.type,
              typeHandlerVersion: model.version,
              autoUpgradeMinorVersion: model.auto_upgrade_minor_version,
              settings: model.settings,
              protectedSettings: model.protected_settings
            }
          }
        end
      end
    end
  end
end

