require 'uri'
require_relative 'request'
require_relative 'poller'

module Azure
  TokenExpired = Class.new(StandardError)

  class Action
    attr_reader :token, :model, :verb, :version, :request, :response, :path

    def initialize(token:, model:, verb:, version:, path: nil, &blk)
      @state = :pending
      @token = token
      @model = model
      @verb = verb
      @version = version
      @path = if path then URI(path) end

      instance_exec(&blk) if blk
    end

    def complete?
      @state == :complete
    end

    def body
      nil
    end

    def params
      { "api-version" => version }
    end

    def base_uri
      if path.nil?
        model.uri
      else
        URI("#{model.uri}#{path}")
      end
    end

    def uri
      base_uri.dup.tap do |u|
        u.query = params.map { |k, v| "#{k}=#{URI.encode(v.to_s)}" }.join("&")
      end
    end

    def to_hash
      if complete?
        response.parsed_body
      end
    end

    def to_model
      fail NotImplementedError
    end

    def make_request
      @request = Request.new(token: token, uri: uri, body: body, verb: verb)
    end

    def responses
      if @responses
        @responses
      else
        [@response].compact
      end
    end

    def call(poll: true)
      make_request
      @request.call
      @response = @request.response

      if response.status == 401
        @state = :error
        fail TokenExpired
      end

      if poll then poll! end

      if response.status > 499
        @state = :error
      else
        @state = :complete
      end
    end

    def poll!
      if response.status == 202
        @responses = [@response]

        poll_uri = URI(response.headers["location"].first)
        poller = Poller.new(token: token, uri: poll_uri)
        poller.call

        @response = poller.response
        @responses << @response
      end
    end
  end
end
