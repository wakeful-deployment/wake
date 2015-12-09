require_relative "../azure/scp"
require_relative "image"
require "json"
require "tmpdir"

module Docker
  class OperatorCommand
    attr_reader :ip, :images

    FILENAME = "operator.json".freeze

    def initialize(ip:, *images)
      @ip = ip
      @images = images

      if @images.all? { |image| String === image }
        @images = @images.map { |image_name| Image.send(image_name) }
      end
    end

    def json
      JSON.generate(images)
    end

    def render!
      File.open(FILENAME, mode: "w") do |f|
        f << operator_json
      end
    end

    def copy!
      SCP.call(ip: ip, local_path: FILENAME)
    end

    def call
      Dir.mktmpdir do |tmpdir|
        Wake.log [:tmpdir, tmpdir]

        Dir.chdir(tmpdir) do
          render!
          copy!
        end
      end
    end
  end
end
