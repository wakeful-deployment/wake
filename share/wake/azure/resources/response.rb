require 'json'

module Azure
  class Response
    attr_reader :request, :code, :body, :headers

    def initialize(request: nil, code:, body: nil, headers: {})
      @request = request
      @code = code
      @body = body
      @headers = headers
    end

    def status
      code.to_i
    end

    def parsed_body
      unless body.nil? || body.empty?
        @parsed_body ||= JSON.parse(body)
      end
    end
  end
end
