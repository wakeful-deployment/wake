require 'uri'
require_relative '../model'

module Azure
  class Vnet
    include SubResource

    parent   :resource_group
    optional :address_prefix, default: "10.0.0.0/8"

    uri { URI("#{resource_group.uri}/providers/Microsoft.Network/virtualnetworks/#{name}") }
  end
end
