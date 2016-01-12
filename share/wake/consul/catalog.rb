require 'forwardable'

module Wake
  module Consul
    class Catalog
      extend Forwardable

      def initialize(consul)
        @consul = consul
      end

      delegate [:run, :curl] => :@consul

      def services
        run curl("/catalog/services")
      end

      def service_info(service)
        run curl("/catalog/service/#{service}")
      end

      def nodes
        run curl("/catalog/nodes")
      end

      def node_info(node)
        run curl("/catalog/node/#{node}")
      end
    end
  end
end
