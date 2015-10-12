require 'net/http'
require 'json'
require 'uri'
require_relative 'token'

module Azure
  class TokenRequest
    GRANT_TYPE = "client_credentials".freeze
    AUDIENCE = URI("https://management.core.windows.net/").freeze

    attr_reader :tenant_id, :client_id, :client_secret, :uri, :response

    def initialize(tenant_id:, client_id:, client_secret:)
      @state = :pending

      @tenant_id = tenant_id
      @client_id = client_id
      @client_secret = client_secret

      @uri = URI("https://login.windows.net/#{tenant_id}/oauth2/token")
    end

    def to_curl
      encoded_request_body = request_body.map do |k,v|
        "#{k}=#{URI.escape(v.to_s)}"
      end.join("&")

      o = "curl"
      o << " -XPOST"
      o << " -H 'Content-type: application/x-www-form-urlencoded'"
      o << " -d '#{encoded_request_body}'"
      o << " '#{uri}'"
    end

    def complete?
      @state == :complete
    end

    def request_body
      {
        resource: AUDIENCE,
        client_id: client_id,
        client_secret: client_secret,
        grant_type: GRANT_TYPE
      }
    end

    def call
      @response = Net::HTTP.post_form(uri, request_body)
      @state = :complete
    end

    def parsed_response_body
      if complete?
        @parsed_response_body ||= JSON.parse(response.body)
      end
    end

    def token
      if complete?
        Token.new(
          type: parsed_response_body["token_type"],
          expires_on: parsed_response_body["expires_on"].to_i,
          resource: parsed_response_body["resource"],
          access_token: parsed_response_body["access_token"]
        )
      end
    end
  end
end

