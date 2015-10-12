require 'securerandom'
require 'uri'
require_relative '../model'

module Azure
  class VM
    include SubResource

    parent   :resource_group
    required :storage_account
    required :nic
    optional :size, default: "Basic_A3"
    boolean  :setup
    optional :host_image_uri
    optional :admin_username, default: "awake"
    optional :admin_password, default: ->{ SecureRandom.urlsafe_base64(32) }
    optional :ssh_key_path,   default: "/home/awake/.ssh/authorized_keys"
    required :ssh_public_key

    uri { URI("#{resource_group.uri}/providers/Microsoft.Compute/virtualMachines/#{name}") }
  end
end
