require 'fileutils'
require 'erb'

class Dockerfile
  attr_reader :sha, :start, :local_path

  def initialize(path:, sha:, start:, target:, env: [])
    @path = path
    @name = File.basename(@path)
    @sha = sha
    @start = start
    @target = target
    @env = env
    @local_path = "#{@target}/#{@name}"
  end

  def mkdir
    FileUtils.mkdir_p(@target)
  end

  def render
    ERB.new(File.read(@path)).result(binding)
  end

  def write!
    mkdir
    File.open(@local_path, "w") do |f|
      f << render
    end
  end
end
