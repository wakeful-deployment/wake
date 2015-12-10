require 'tmpdir'
require 'json'

module Azure
  module Setup
    module Dockerable
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def boot_images(*images)
          if images && image.length > 0
            @boot_images = images.map { |image_name| DockerImage.send(image_name) }
          else
            @boot_images
          end
        end
      end

      def operator_boot_script_path
        File.expand_path("../operator_boot", __FILE__)
      end

      def boot_images
        self.class.boot_images.map do |image_name|
          DockerImage.send(image_name)
        end
      end

      def operator_json
        JSON.pretty_generate(boot_images: boot_images)
      end

      def write_and_copy_operator_files
        Dir.mktmpdir do |tmpdir|
          Wake.log [:tmpdir, tmpdir]

          Dir.chdir(tmpdir) do
            File.open("operator.json", "w") do |f|
              f << operator_json
            end
            SCP.call(ip: ip, local_path: "operator.json")
            SCP.call(ip: ip, local_path: operator_boot_script_path)
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
          ports: [{
            incoming: 8125,
            outgoing: 8125,
            udp: true
          }]
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
          ports: [{
            incoming: 8300,
            outgoing: 8300
          }, {
            incoming: 8301,
            outgoing: 8301
          }, {
            incoming: 8301,
            outgoing: 8301,
            udp: true
          }, {
            incoming: 8302,
            outgoing: 8302,
            udp: true
          }, {
            incoming: 8400,
            outgoing: 8400
          }, {
            incoming: 8500,
            outgoing: 8500
          }, {
            incoming: 8600,
            outgoing: 8600
          }, {
            incoming: 8600,
            outgoing: 8600,
            udp: true
          }]
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
          "env"   => env,
          "name"  => name,
          "image" => image,
          "ports" => ports
        }
      end
    end
  end
end
