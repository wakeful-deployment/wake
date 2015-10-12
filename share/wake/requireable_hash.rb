require "delegate"

class WrappedArray < SimpleDelegator
  def [](index)
    value = super
    wrap(value)
  end

  def to_ary
    __get_obj__
  end
  alias_method :to_a, :to_ary

  private

  def wrap(value)
    if value.is_a?(Hash)
      RequireableHash.new(value)
    elsif value.is_a?(Array)
      self.class.new(value)
    else
      value
    end
  end
end

class RequireableHash < SimpleDelegator
  class Error < StandardError; end
  class CannotCreate < StandardError; end
  class CannotUpdate < StandardError; end

  class Key
    def initialize(name)
      @name = name
    end

    def get(h)
      if h.is_a?(Hash)
        h[@name]
      end
    end

    def self.default
      {}
    end

    def get_or_create(h, default:)
      if h.is_a?(Hash)
        h[@name] ||= default
      else
        fail CannotCreate
      end
    end

    def key?(h)
      if h.is_a?(Hash)
        h.key?(@name)
      end
    end

    def update(h, value:)
      if h.is_a?(Hash)
        h[@name] = value
      else
        fail CannotUpdate
      end
    end

    def delete(h)
      if h.is_a?(Hash)
        h.delete(@name)
      end
    end
  end

  class Index
    def initialize(number)
      @number = number
    end

    def get(a)
      if a.is_a?(Array)
        a[@number]
      end
    end

    def self.default
      []
    end

    def get_or_create(a, default:)
      if a.is_a?(Array)
        a[@number] ||= default
      else
        fail CannotCreate
      end
    end

    def key?(a)
      if a.is_?(Array)
        !a[@number].nil?
      end
    end

    def update(a, value:)
      if a.is_a?(Array)
        a[@number] = value
      else
        fail CannotUpdate
      end
    end

    def delete(a)
      if a.is_a?(Array)
        a.delete_at(@number)
      end
    end
  end

  class KeysAndIndexes
    attr_reader :ops

    def initialize(ops)
      @ops = ops
    end

    def get(thing)
      ops.reduce(thing) do |sub_thing, op|
        op.get(sub_thing)
      end
    end

    def key?(thing)
      list = ops[0..-2]

      bottom_thing = list.reduce(thing) do |sub_thing, op|
        op.get(sub_thing)
      end

      if bottom_thing
        ops.last.key?(bottom_thing)
      end
    end

    def update(thing, value:)
      ops_to_create_through = ops[0..-2]
      shifted = ops[1..-1]
      list = ops_to_create_through.zip(shifted)

      bottom_thing = list.reduce(thing) do |sub_thing, (op, next_op)|
        op.get_or_create(sub_thing, default: next_op.class.default)
      end

      ops.last.update(bottom_thing, value: value)
    end

    def delete(thing)
      list = ops[0..-2]

      bottom_thing = list.reduce(thing) do |sub_thing, op|
        op.get(sub_thing)
      end

      if bottom_thing
        ops.last.delete(bottom_thing)
      end
    end

    def self.normalize_dots(string)
      string.gsub(/\[(\d+)\]/, '.[\\1].').gsub(/\.{2,}/, '.')
    end

    def self.parse(string)
      normalize_dots(string).split('.').map do |s|
        if s =~ /\A\[(\d+)\]\z/
          Index.new($1.to_i)
        else
          Key.new(s)
        end
      end
    end

    def self.from(string)
      new(parse(string))
    end
  end

  def key?(key)
    KeysAndIndexes.from(key).key?(to_hash)
  end

  def [](key)
    value = KeysAndIndexes.from(key).get(to_hash)
    wrap(value)
  end

  def []=(key, value)
    update(key, value)
  end

  def require(key)
    value = KeysAndIndexes.from(key).get(to_hash)

    fail(Error.new("no key '#{key}'")) if value.nil?

    wrap(value)
  end

  def update(key, value)
    KeysAndIndexes.from(key).update(to_hash, value: value)
  end

  def delete(key)
    KeysAndIndexes.from(key).delete(to_hash)
  end

  def to_hash
    __getobj__
  end
  alias_method :to_h, :to_hash

  private

  def wrap(value)
    if value.is_a?(Hash)
      self.class.new(value)
    elsif value.is_a?(Array)
      WrappedArray.new(value)
    else
      value
    end
  end
end
