require 'erb'
require 'tmpdir'
require_relative 'ssh'
require_relative 'scp'
require_relative 'provisioning_state_poller'

module Azure
  class Setup
    attr_reader :ip, :collaborators, :vm

    def initialize(collaborators:, ip:, vm:, type:)
      @collaborators = collaborators
      @ip            = ip
      @vm            = vm
      @type          = type
    end

    def fetch_public_key(name)
      uri = URI("https://github.com/#{name}.keys")
      keys = Net::HTTP.get(uri).chomp
    end

    def fetch_collaborators
      collaborators.map do |c|
        [c, fetch_public_key(c)]
      end
    end

    def template
      File.read(File.expand_path("../setup.sh.erb", __FILE__))
    end

    def render
      ERB.new(template).result(binding)
    end

    def render_and_copy_setup_sh
      Dir.mktmpdir do |tmpdir|
        Wake.log [:tmpdir, tmpdir]

        Dir.chdir(tmpdir) do
          File.open("setup.sh", "w") do |f|
            f << render
          end
          SCP.call(ip: ip, local_path: "setup.sh")
        end
      end
    end

    def install_docker
      extension = Azure::Extension.docker(vm: vm)
      Azure.resources.extensions.put!(extension)
      Azure::ProvisioningStatePoller.call(resource: Azure.resources.extensions, model: extension)
    end

    def call
      # TODO: use @type to determine what to do
      install_docker
      local_sshd_config = File.expand_path("../sshd_config", __FILE__)
      SCP.call(ip: ip, local_path: local_sshd_config)
      render_and_copy_setup_sh
      SSH.call(ip: ip, command: ". setup.sh")
    end

    def self.call(**opts)
      new(**opts).call
    end
  end
end
