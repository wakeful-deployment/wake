require_relative "../ssh"
require 'erb'
require 'tmpdir'

module Azure
  module Setup
    module Setupable
      def self.included(base)
      base.extend(ClassMethods)
    end

      module ClassMethods
        def setup_sh_path(path = nil)
          if path
            @setup_sh_path = path
          else
            @setup_sh_path
          end
        end
      end

      def setup_sh_template
        File.read(File.expand_path("../#{self.class.setup_sh_path}", __FILE__))
      end

      def render_setup_sh
        ERB.new(setup_sh_template).result(binding)
      end

      def render_and_copy_setup_sh
        Dir.mktmpdir do |tmpdir|
          Wake.log [:tmpdir, tmpdir]

          Dir.chdir(tmpdir) do
            File.open("setup.sh", "w") do |f|
              f << render_setup_sh
            end
            SCP.call(ip: ip, local_path: "setup.sh")
          end
        end
      end

      def run_setup
        render_and_copy_setup_sh
        SSH.call(ip: ip, command: "sudo chmod +x setup.sh && sudo ./setup.sh && rm setup.sh")
      end
    end
  end
end
