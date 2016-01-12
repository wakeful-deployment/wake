require 'json'
require 'shellwords'
require_relative 'consul/catalog'
require_relative 'consul/kv'
require_relative 'consul/env'

module Wake
  module Consul
    ConsulCurlFailed = Class.new(StandardError)

    class Base
      def initialize(cluster)
        @cluster = cluster
      end

      def curl(url, opts = nil)
        # Shellwords is alright here because we know we are running this curl on linux/bash
        url = Shellwords.escape("http://localhost:8500/v1#{url}")
        "curl -f -q #{opts} #{url}"
      end

      def run(string)
        command = @cluster.ssh_proxy.run string

        if command.success?
          begin
            JSON.parse(command.output)
          rescue JSON::ParserError
            command.output
          end
        else
          fail ConsulCurlFailed, command.error
        end
      end

      def catalog
        @catalog ||= Catalog.new(self)
      end

      def kv
        @kv ||= KV.new(self)
      end

      def env
        @env ||= ENV.new(kv)
      end
    end
  end
end
