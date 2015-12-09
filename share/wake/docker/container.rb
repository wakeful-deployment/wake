require_relative "image"

module Docker
  class Container
    attr_reader :name, :image, :ports

    def initialize(name:, image:, ports: [])
      @name  = name
      @image = image
      @ports = ports

      if @ports.all? { |port| String === port }
        @ports = @ports.map { |port| DockerPort.new_from_string(port) }
      end

      if String === @image
        @image = Image.new_from_string(@image)
      end
    end

    def to_hash
      {
        name: name,
        image: image.to_s,
        ports: ports
      }
    end

    def self.statsite
      new(
        name: "statsite",
        image: "wake-statsite",
        ports: %w(8125:8125/udp)
      )
    end

    def self.server
      consul(:server)
    end

    def self.agent
      consul(:agent)
    end

    def self.consul(type)
      new(
        name: "consul",
        image: "wake-consul-#{type}",
        ports: %w(
          8300:8300
          8301:8301
          8301:8301/udp
          8302:8302/udp
          8400:8400
          8500:8500
          8600:8600
          8600:8600/udp
        )
      )
    end
  end
end
