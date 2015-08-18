require 'bundler/setup'
require 'azure'
require_relative './config'

module Wake
  module Azure
    module VirtualMachines
      module_function

      def vm_image_manager
        configure!
        ::Azure.vm_image_management
      end

      def vm_manager
        configure!
        ::Azure.vm_management
      end

      def configure!
        management_certificate_path = Wake::Azure::Config.get_management_certificate!
        ::Azure.management_certificate = management_certificate_path
        ::Azure.subscription_id = WakeConfig.get_or_ask_for("azure.subscription.id")
      end
    end
  end
end
