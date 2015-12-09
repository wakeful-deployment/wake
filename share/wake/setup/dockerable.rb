require 'tmpdir'
require 'yaml'

module Azure
  class DockerPort
    attr_reader :from, :to, :udp

    def initialize(from:, to: nil, udp: false)
      @from = from
      @to = to || @from
      @udp = !!udp
    end

    def udp_string
      if udp
        "/udp"
      else
        ""
      end
    end

    def to_s
      "#{from}:#{to}#{udp_string}"
    end

    def self.new_from_string(string)
      ports, udp_string = string.split("/")

      udp = (udp_string == "udp")
      from, to = ports.split(":")

      new(from: from, to: to, udp: udp)
    end
  end

end
