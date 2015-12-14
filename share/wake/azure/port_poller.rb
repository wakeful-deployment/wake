module Azure
  class PortPoller
    attr_reader :ip, :port, :tries, :max_tries

    def initialize(ip:, port:, max_tries: 100)
      @ip        = ip
      @port      = port
      @tries     = 0
      @max_tries = max_tries
    end

    def call
      loop do
        `nc -z -w5 #{ip} #{port} 2&>1 /dev/null`

        if $?.success?
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
