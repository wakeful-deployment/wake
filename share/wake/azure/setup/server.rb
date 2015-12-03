require 'tmpdir'
require 'yaml'
require_relative '../scp'

module Azure
  module Setup
    class Server
      include Dockerable

      compose :statsite, :server

      def setup_server_sh_path
        File.expand_path("../setup_server.sh", __FILE__)
      end

      def copy_setup_server_sh
        SCP.call(ip: ip, local_path: setup_server_sh_path)
      end

      def call
        write_and_copy_compose
        copy_setup_server_sh
        SSH.call(ip: ip, command: "sudo chmod +x setup_server.sh && sudo ./setup_server.sh && rm setup_server.sh")
      end
    end
  end
end
