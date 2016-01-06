require 'shellwords'
require_relative '../run'
require_relative '../exec'

module Azure
  class SSH
    attr_reader :ip, :username, :command, :output, :error, :status

    def github_username
      WakeConfig.get_or_ask_for("github.username")
    end

    def initialize(ip:, username: github_username, command: nil, force_exec: false)
      @ip         = ip
      @username   = username
      @command    = command && Wake.escape(command)
      @force_exec = force_exec
    end

    def command?
      !!command
    end

    def force_exec?
      !!@force_exec
    end

    def ssh_command
      "ssh -A -t -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no #{username}@#{ip}"
    end

    def full_command
      if command?
        "#{ssh_command} #{command}"
      else
        ssh_command
      end
    end

    def call
      Wake.log [:command, full_command]

      if command? && !force_exec?
        @output, @error, @status = run full_command
      else
        Wake.exec full_command
      end
    end

    def exitstatus
      if @status
        @status.exitstatus
      end
    end

    def self.call(**opts)
      new(**opts).tap { |s| s.call }
    end
  end
end
