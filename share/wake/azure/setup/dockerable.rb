require 'tmpdir'
require 'yaml'

module Azure
  module Dockerable
    def self.included(base)
      extend ClassMethods
    end

    module ClassMethods
      def compose(*images)
        if images
          @compose = images.map { |image_name| DockerImage.send(image_name) }
        else
          @compose
        end
      end
    end

    def compose_info
      DockerCompose.new(self.class.compose)
    end

    def compose_yml
      YAML.dump compose_info.to_hash
    end

    def compose_script_path
      File.expand_path("../compose", __FILE__)
    end

    def write_and_copy_compose
      Dir.mktmpdir do |tmpdir|
        Wake.log [:tmpdir, tmpdir]

        Dir.chdir(tmpdir) do
          File.open("docker-compose.yml", "w") do |f|
            f << compose_yml
          end
          SCP.call(ip: ip, local_path: "docker-compose.yml")
          SCP.call(ip: ip, local_path: compose_script_path)
        end
      end
    end
  end

  class DockerImage
    attr_reader :repo, :name, :org, :rev, :ports, :env

    def docker_hub_organization
      WakeConfig.get_or_ask_for("docker.hub.organization")
    end

    def self.statsite
      DockerImage.new(
        repo: "wake-statsite",
        name: "statsite",
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
      DockerImage.new(
        repo: "wake-consul-#{type}",
        name: "consul",
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

    def initialize(repo:, name:, org: docker_hub_organization, rev: :latest, ports: [], env: [])
      @repo  = repo
      @name  = name
      @org   = org
      @rev   = rev
      @ports = ports
      @env   = env
    end

    def image
      "#{org}/#{repo}:#{rev}"
    end

    def to_hash
      {
        "environment"    => env,
        "container_name" => name,
        "image"          => image,
        "ports"          => ports
      }
    end
  end

  class DockerCompose
    def initialize(images)
      @images = images
    end

    def to_hash
      images.each_with_object({}) do |h, image|
        h[image.name] = image.to_hash
      end
    end
  end
end
