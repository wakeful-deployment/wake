require_relative '../config'
require_relative '../panic'

module Wake
  module Azure
    module Config
      module_function

      def get_publish_settings
        File.join(CONFIG_DIR, "azure", "wake.publishsettings")
      end

      def get_publish_settings!
        publish_settings = get_publish_settings

        unless File.exists?(publish_settings)
          panic!(
            """
Could not find azure publish settings in wake config directory.
Please add your publish settings to '#{publish_settings}'.

You can download the settings here: https://manage.windowsazure.com/publishsettings
            """
          )
        end

        publish_settings
      end

      def get_management_certificate
        File.join(CONFIG_DIR, "azure", "wake.pfx")
      end

      def get_management_certificate!
        management_certificate = get_management_certificate

        unless File.exists?(management_certificate)
          panic!(
            """
Could not find azure management certificate in wake config directory.
Please add your management certificate to '#{management_certificate}'.

TODO: describe how to add this.
            """
          )
        end

        management_certificate
      end
    end
  end
end
