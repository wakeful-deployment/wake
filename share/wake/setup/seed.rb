require_relative 'commands'
require 'erb'
require 'resolv'

module Wake
  module Setup
    class Seed
      attr_reader :cluster, :ip, :vm, :docker_user

      def initialize(cluster:, ip:, vm:, docker_user:)
        @cluster     = cluster
        @ip          = ip
        @vm          = vm
        @docker_user = docker_user
      end

      def fetch_public_key(name)
        uri = URI("https://github.com/#{name}.keys")
        keys = Net::HTTP.get(uri).chomp
      end

      def fetch_collaborators
        cluster.collaborators.map do |c|
          [c, fetch_public_key(c)]
        end
      end

      # TODO: move to azure folder
      def dns_zone
        Azure::DNSZone.new(resource_group: cluster.azure.resource_group, name: cluster.require("dns_zone"))
      end

      # TODO: move to azure folder
      def ns_servers
        result   = Azure.resources.dns_zones.record_sets!(dns_zone)
        body     = result.response.parsed_body
        ns_set   = body["value"].find { |s| s["id"] =~ %r{NS/@$} }
        ns_set["properties"]["NSRecords"].flat_map(&:values)
      end

      def call
        Commands::CopyFiles.new(ip).call "sshd_config", "docker.conf"
        Commands::DNSMasqConf.new(ip).call *ns_records
        Commands::OperatorConf.new(ip).call :statsite
        Commands::ShellScript.new(ip).call template: "seed.sh.erb", collaborators: fetch_collaborators, docker_user: docker_user
      end
    end
  end
end
