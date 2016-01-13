require 'json'

module Wake
  module Consul
    class Directory
      extend Forwardable

      SERVICE_PATH_REGEX = %r{\A_wakeful/nodes/\w+/services/\w+\z}.freeze

      def initialize(kv)
        @kv = kv
      end

      def everything
        array = @kv.get("_wakeful/nodes", recurse: true)

        array.each_with_object({}) do |pair, h|
          name  = pair[:name]
          value = pair[:value]
          path  = pair[:path]
          parts = path.split("/")

          # make deep hashes if they are not already there
          inner_hash = parts[0..-2].reduce(h) do |inner_h, part|
            inner_h[part] ||= {}
          end

          if path =~ SERVICE_PATH_REGEX
            value = JSON.parse(value)
          end

          inner_hash[name] = value
        end
      end

      def service_path(node, service)
        "_wakeful/nodes/#{node}/services/#{service}"
      end

      def add_service(node:, service:)
        service_name = service.delete(:name)
        key = service_path(node, service_name)
        @kv.put(key, JSON.generate(service))
      end

      def remove_service(node:, name:)
        key = service_path(node, name)
        @kv.del(key)
      end
    end
  end
end
