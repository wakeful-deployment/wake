require_relative 'resources/resource'

module Azure
  def self.setup_resources(&blk)
    unless defined?(@resources)
      @resources = Resources.new
    end

    @resources.instance_exec(&blk)

    unless respond_to?(:resources)
      define_singleton_method :resources do |token: Azure.token_provider|
        @resources.with_token(token)
      end
    end
  end

  class Resources
    attr_reader :token

    def initialize(token: nil)
      @resources = {}
      @token     = token
    end

    def resources(name, &blk)
      resource = Resource.new(name, resources: self).tap { |r| r.instance_exec(&blk) }
      @resources[name] = resource

      define_singleton_method name do
        resource
      end
    end

    def with_token(token)
      @token = token
      self
    end
  end
end
