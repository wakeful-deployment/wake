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
        run(curl("/catalog/services"))
      end

      def service(service)
        run(curl("/catalog/service/#{service}"))
      end

      def nodes
        run(curl("/catalog/nodes")).map do |h|
          {
            name: h["Node"],
            ip: h["Address"]
          }
        end
      end

      def node(node)
        h = run(curl("/catalog/node/#{node}"))

        services = h["Services"].each_with_object({}) do |(k, v), hash|
          address = v["Address"]
          address = nil if address.empty?

          tags = v["Tags"]
          tags = [] if tags.nil? || tags.empty?

          port = v["Port"]
          port = nil if port == 0

          hash[k] = {
            name: k,
            tags: tags,
            address: address,
            port: port
          }
        end

        {
          name: h["Node"]["Node"],
          ip: h["Node"]["Address"],
          services: services
        }
      end
    end
  end
end
