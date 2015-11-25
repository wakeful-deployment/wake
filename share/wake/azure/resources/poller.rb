require_relative 'request'

module Azure
  class Poller
    Timeout = Class.new(StandardError)

    attr_reader :token, :uri, :timeout, :response

    def initialize(token:, uri:, timeout: 600)
      @state = :pending
      @token = token
      @uri = uri
      @now = Time.now.to_i
      @timeout = timeout
    end

    def timeout?
      (Time.now.to_i - @now) >= timeout
    end

    def call
      loop do
        request = Request.new(token: token, uri: uri, verb: :get)
        request.call
        response = request.response

        if [200, 201, 204].include? response.status
          @response = response
          @state = :complete
          break
        end

        if timeout?
          @state = :error
          fail Timeout
        end

        if response.status > 499
          sleep 5 # allow the server time to feel better
        else
          sleep 1
        end
      end
    end
  end
end
