require_relative 'token_request'

module Azure
  class TokenProvider
    def initialize(token: nil, tenant_id:, client_id:, client_secret:)
      @token = token
      @tenant_id = tenant_id
      @client_id = client_id
      @client_secret = client_secret
    end

    def expires_soon?
      @token.nil? || @token.expires_soon?
    end

    def request!
      request = TokenRequest.new(tenant_id: @tenant_id,
                                 client_id: @client_id,
                                 client_secret: @client_secret)
      request.call
      @token = request.token
    end

    def access_token
      request! if expires_soon?
      @token.access_token
    end

    def to_header
      request! if expires_soon?
      @token.to_header
    end

    def to_hash
      request! if expires_soon?
      @token.to_hash
    end
  end
end
