require 'shellwords'
require_relative 'run'

module Azure
  class SSH
    attr_reader :ip, :username, :command, :output, :error, :status

    def github_username
      WakeConfig.get_or_ask_for("github.username")
    end

    def initialize(ip:, username: github_username, command: nil)
      @ip       = ip
      @username = username
      @command  = command && Shellwords.escape(command)
    end

    def command?
      !!command
    end

    def ssh_command
      "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no #{username}@#{ip}"
    end

    def call
      if command?
        @output, @error, @status = run "#{ssh_command} #{command}"
      else
        exec ssh_command
      end
    end

    def exitstatus
      if @status
        @status.exitstatus
      end
    end

    def self.call(**opts)
      new(**opts).call
    end
  end
end
