require "delegate"

class RequireableHash < SimpleDelegator
  class Error < StandardError; end

  def initialize(name, hash)
    @name = name
    super(hash)
  end

  def [](key)
    value = super
    wrap(value, key)
  end

  def require(key)
    value = fetch(key) { raise Error }
    wrap(value, key)
  end

  private

  def wrap(value, key)
    if value.is_a?(Hash)
      self.class.new(@name, value)
    else
      value
    end
  end
end
