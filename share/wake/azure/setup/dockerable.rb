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
          if images && images.length > 0
            @boot_images = images
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
          DockerImage.send(image_name, cluster)
        end
      end

      def operator_json
        JSON.pretty_generate(services: services_hash)
      end

      def services_hash
        boot_images.each_with_object({}) do |hash, i|
          hash[i.name] = i.to_hash
        end
      end

      def write_and_copy_operator_json
        Dir.mktmpdir do |tmpdir|
          Wake.log [:tmpdir, tmpdir]

          Dir.chdir(tmpdir) do
            File.open("operator.json", mode: "w", universal_newline: true) do |f|
              f << operator_json
            end
            SCP.call(ip: ip, local_path: "operator.json")
          end
        end
      end

      def copy_operator_boot
        SCP.call(ip: ip, local_path: operator_boot_script_path)
      end
    end

    class DockerImage
      attr_reader :repo, :name, :org, :rev, :ports, :env

      def docker_hub_organization
        WakeConfig.get_or_ask_for("docker.hub.organization")
      end

      def self.operator(cluster = nil)
        DockerImage.new(
          repo: "wake-operator",
          rev: "c60758244",
          name: "operator",
          ports: [],
          env: {}
        )
      end

      def self.statsite(cluster = nil)
        DockerImage.new(
          repo: "wake-statsite",
          name: "statsite",
          ports: [{
            incoming: 8125,
            outgoing: 8125,
            udp: true
          }],
          env: {}
        )
      end

      def self.server(cluster)
        consul(:server, cluster)
      end

      def self.agent(cluster)
        consul(:agent, cluster)
      end

      def self.consul(type, cluster)
        DockerImage.new(
          repo: "wake-consul-#{type}",
          name: "consul",
          env: {
            "BOOTSTRAP_EXPECT" => "3",
            "JOINDNS" => "consul.#{cluster.require("dns_zone")}",
            "ADVERTISE" => "$CONSULHOST",
            "NODE" => "$NODE"
          },
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
            outgoing: 8302
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
          "image" => image,
          "ports" => ports
        }
      end
    end
  end
end
