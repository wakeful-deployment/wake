require 'shellwords'
require_relative '../run'

module Azure
  class SSH
    attr_reader :ip, :user, :command, :output, :error, :status

    def initialize(ip:, user: "awake", command: nil)
      @ip      = ip
      @user    = user
      @command = command && Shellwords.escape(command)
    end

    def command?
      !!command
    end

    def ssh_command
      "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no #{user}@#{ip}"
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
