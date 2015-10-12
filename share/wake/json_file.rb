require 'json'
require_relative "requireable_hash"

class JSONFile
  def initialize(path)
    @path = path
    @name = File.basename(path)
    @content = RequireableHash.new(JSON.parse(File.read(path)).to_hash)
  rescue Errno::ENOENT
    fail "#{@path} not found"
  rescue JSON::ParserError
    fail "#{@path} is malformed"
  end

  def key?(key)
    @content.key?(key)
  end

  def [](key)
    @content[key]
  end

  def []=(key, value)
    @content.update(key, value)
  end

  def require(key)
    @content.require(key)
  rescue RequireableHash::Error
    fail "#{@path} is missing the required key: #{key}"
  end

  def update(key, value)
    @content.update(key, value)
  end

  def delete(key)
    @content.delete(key)
  end

  def persist
    File.open(@path, "w") do |f|
      f << JSON.pretty_generate(@content)
    end
    nil
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
