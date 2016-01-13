require_relative 'json_file'
require_relative 'root'

module Wake
  MissingManifest = Class.new StandardError

  class Manifest
    attr_reader :platform, :app, :processes, :owners

    def self.exists?(path = "./manifest.json")
      File.exists?(path)
    end

    def initialize(path = "./manifest.json")
      unless self.class.exists?(path)
        fail MissingManifest, "Could not find manifest.json at '#{path}'"
      end

      @path      = path
      @file      = JSONFile.new(@path)
      @platform  = @file.require("platform")
      @app       = @file.require("app")
      @processes = @file.require("processes")
      @owners    = @file["owners"] || []
    end

    def dockerfile?
      File.exists? dockerfile_path
    end

    def dockerfile
      File.join(WAKE_ROOT, "platforms", "wake", platform, "Dockerfile")
    end

    def to_h
      @file.to_h
    end
  end
end
