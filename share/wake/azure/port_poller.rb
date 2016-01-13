require 'socket'

module Azure
  class PortPoller
    attr_reader :ip, :port, :tries, :max_tries

    def initialize(ip:, port:, max_tries: 100)
      @ip        = ip
      @port      = port
      @tries     = 0
      @max_tries = max_tries
    end

    def is_port_open?(ip, port)
      begin
        TCPSocket.new(ip, port)
      rescue
        return false
      end
      return true
    end

    def call
      loop do
        if is_port_open? ip, port
          break
        elsif tries >= max_tries
          fail "port #{port} never became available"
        else
          @tries += 1
          sleep 3
        end
      end
    end

    def self.call(**opts)
      new(**opts).call
    end
  end
end
