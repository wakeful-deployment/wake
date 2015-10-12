require 'uri'
require_relative '../model'

module Azure
  class ResourceGroup
    include Model

    parent   :subscription
    required :name
    required :location

    uri { URI("#{subscription.uri}/resourceGroups/#{name}") }
  end
end
