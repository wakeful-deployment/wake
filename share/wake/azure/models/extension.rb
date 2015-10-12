require 'uri'
require_relative '../model'

module Azure
  class Extension
    include Model

    parent   :vm
    required :type
    required :version
    optional :resource_group,             default: ->{ parent.resource_group }
    optional :location,                   default: ->{ parent.location }
    optional :name,                       default: ->{ "#{vm.name}-#{type}" }
    optional :publisher,                  default: "Microsoft.Azure.Extensions"
    boolean  :auto_upgrade_minor_version, default: true
    optional :settings,                   default: {}
    optional :protected_settings,         default: {}

    uri { URI("#{vm.uri}/extensions/#{name}") }

    def self.docker(**opts)
      new(type: "DockerExtension", version: "1.0", **opts)
    end
  end
end
