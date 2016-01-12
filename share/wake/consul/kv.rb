require 'forwardable'
require 'shellwords'

module Wake
  module Consul
    Pair = Struct.new(:path, :name, :value)

    class KV
      extend Forwardable

      def initialize(consul)
        @consul = consul
      end

      delegate [:run, :curl] => :@consul

      def put(key, value)
        # Shellwords is alright here because we know we are running this curl on linux/bash
        value = Shellwords.escape(value)
        run curl("/kv/#{key}", "-XPUT -d #{value}")
        true
      end

      private def extract_kv_pair(h)
        path = h["Key"]
        name = path.split("/").last
        value = h["Value"].unpack(?m).first

        Pair.new path, name, value
      end

      def get(key, recurse: false)
        pairs = run(curl("/kv/#{key}?recurse")).map do |h|
          extract_kv_pair h
        end

        if recurse
          pairs
        else
          pairs.first
        end
      end

      def delete(key)
        run curl("/kv/#{key}", "-XDELETE")
        true
      end

      alias_method :del, :delete
    end
  end
end
