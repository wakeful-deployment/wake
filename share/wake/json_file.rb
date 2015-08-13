require 'json'
require_relative "requireable_hash"
require_relative "panic"

class JSONFile
  def initialize(path)
    @path = path
    @name = File.basename(path)
    @content = RequireableHash.new(@path, JSON.parse(File.read(path)))
  rescue Errno::ENOENT
    panic! "#{@path} not found"
  rescue JSON::ParserError
    panic! "#{@path} is malformed"
  end

  def [](key)
    key.split(".").reduce(@content) do |c, name|
      c[name] || return
    end
  end

  def []=(key, value)
    update(key, value)
  end

  def require(key)
    key.split(".").reduce(@content) do |c, name|
      c.require(name)
    end
  rescue RequireableHash::Error
    panic! "#{@path} is missing the required key: #{key}"
  end

  def update(key, value)
    keys = key.split(".")
    traversal_keys = keys[0..-2]
    bottom_hash = traversal_keys.reduce(@content) do |h, k|
      h[k] ||= {}
    end
    bottom_hash[keys.last] = value
  end

  def persist
    File.open(@path, "w") do |f|
      f << JSON.pretty_generate(@content)
    end
  end

  def empty?
    @content.nil? || @content.empty?
  end

  def each(&blk)
    @content.each(&blk)
  end

  def map(&blk)
    @content.map(&blk)
  end
end
