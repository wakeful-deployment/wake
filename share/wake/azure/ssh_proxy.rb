require 'shellwords'
require_relative 'ssh'
require_relative '../config'

module Azure
  class SSHProxy
    attr_reader :ssh, :ip, :user

    def initialize(cluster:, user: WakeConfig.get_or_ask_for("github.username"))
      @ip = cluster.require("sshproxy")
      @user = user
      @state = :pending
    end

    def poll
      Azure::PortPoller.call(ip: @ip, port: 22)
    end

    def run!(command)
      run(command)

      unless @ssh.status.success?
        $stderr.puts "remote command failed"
        $stderr.puts output
        $stderr.puts error
        exit exitstatus
      end

      self
    end

    def run(command)
      if @state == :pending
        @ssh = Azure::SSH.call(ip: @ip, username: @user, command: command)
        @state = :complete
        self
      else
        fail "Cannot use an SSHProxy more than once"
      end
    end

    def output
      @ssh.output if @state == :complete
    end

    def error
      @ssh.error if @state == :complete
    end

    def exitstatus
      @ssh.exitstatus if @state == :complete
    end
  end
end
