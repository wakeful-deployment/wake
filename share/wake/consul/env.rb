require 'forwardable'

module Wake
  module Consul
    InvalidEnvironmentVariableName = Class.new(StandardError)
    InvalidEnvironmentVariableValue = Class.new(StandardError)

    class ENV
      extend Forwardable

      REGEX = /\A[A-Z0-9_]+\z/.freeze
      BASE_PATH = "_wakeful/_env".freeze

      def initialize(kv)
        @kv = kv
      end

      def url(app, name = nil)
        if name.nil?
          "#{BASE_PATH}/#{app}"
        else
          "#{BASE_PATH}/#{app}/#{name}"
        end
      end

      private def validate!(name, value = nil)
        fail(InvalidEnvironmentVariableName, "cannot use #{name}") unless name =~ REGEX

        if value
          fail(InvalidEnvironmentVariableValue, "cannot use #{value}") unless String === value
        end
      end

      def get_all(app:)
        @kv.get(url(app), recurse: true).each_with_object({}) do |pair, hash|
          hash[pair[:name]] = pair[:value]
        end
      rescue ConsulCurlFailed
        {}
      end

      def get(app:, name:)
        validate! name
        @kv.get(url(app, name))[:value]
      rescue ConsulCurlFailed
        nil
      end

      def set(app:, name:, value:)
        validate! name, value
        @kv.put(url(app, name), value)
      end

      def unset(app:, name:)
        validate! name
        @kv.delete(url(app, name))
      end
    end
  end
end
