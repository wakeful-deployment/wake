module Azure
  class Token
    attr_reader :type, :expires_on, :resource, :access_token

    def initialize(type:, expires_on:, resource:, access_token:)
      @type = type
      @expires_on = expires_on
      @resource = resource
      @access_token = access_token
    end

    def expired?
      (@expires_on - Time.now.to_i) <= 0
    end

    def expires_soon?
      (@expires_on - Time.now.to_i) <= 300
    end

    def to_header
      "#{type} #{access_token}"
    end

    def to_hash
      {
        type: type,
        expires_on: expires_on,
        resource: resource,
        access_token: access_token
      }
    end
  end
end
