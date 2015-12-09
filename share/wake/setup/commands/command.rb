require "erb"

module Wake
  module Setup
    module Commands
      class Command
        attr_reader :ip

        def initialize(ip)
          @ip = ip
        end

        def call(*args)
          fail NotImplementedError
        end

        def expand_path(path)
          File.expand_path("../../#{path}", __FILE__)
        end


        def render(template_path, **opts)
          template = File.read(expand_path(template_path))

          klass = Class.new do
            def get_binding; binding() end

            opts.each do |key, value|
              define_method(key) { value }
            end
          end

          ERB.new(template).result(klass.new.get_binding)
        end

        def using_tmpdir
          Dir.mktmpdir do |tmpdir|
            Wake.log [:tmpdir, tmpdir]

            Dir.chdir(tmpdir) do
              yield
            end
          end
        end

        def copy(filename)
          SCP.call(ip: ip, local_path: filename)
        end

        def write(filename, content)
          File.open(filename, "w") do |f|
            f << content
          end
        end

        def write_and_copy(filename, content)
          using_tmpdir do
            write filename, content
            copy filename
          end
        end
      end
    end
  end
end
