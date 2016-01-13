require_relative 'dockerable'
require_relative 'setupable'

module Azure
  module Setup
    class Agent
      include Dockerable
      include Setupable

      boot_images :statsite, :agent
      setup_sh_path "setup_consul.sh"

      attr_reader :cluster, :ip, :vm, :docker_user

      def initialize(cluster:, ip:, vm:, docker_user:)
        @cluster     = cluster
        @ip          = ip
        @vm          = vm
        @docker_user = docker_user
      end

      def call
        write_and_copy_operator_json
        run_setup
      end
    end
  end
end
