require_relative "command"
require_relative "../../scp"

module Wake
  module Setup
    module Commands
      class CopyFiles < Command
        def call(*paths)
          paths = Array(paths).each do |path|
            copy expand_path(path)
          end
        end
      end
    end
  end
end
