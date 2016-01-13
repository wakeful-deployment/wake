require "fileutils"
require_relative "json_file"

CONFIG_DIR = File.expand_path(File.join("~", ".wake"))
path = File.expand_path(File.join(CONFIG_DIR, "config"))

unless File.exists?(path)
  FileUtils.mkdir_p(File.dirname(path))
  File.open(path, mode: "w", universal_newline: true) do |f|
    f << "{}"
  end
end

WAKE_CONFIG = JSONFile.new(path)

module WakeConfig
  module_function

  def format(value, keys)
    value.gsub!(/ /, ' ') # non-breaking space so column will do the right thing

    out = "#{keys.join(".")}\t#{value}"

    out.gsub!(/\.\[/, '[') # remove . from before [0] so arrays look better

    out
  end

  def map(array, keys = [])
    array.each_with_index.map do |v, index|
      keys.push("[#{index}]")
      output = if v.is_a?(Hash)
        traverse(v, keys)
      elsif v.is_a?(Array)
        map(v, keys)
      else
        format(v, keys)
      end
      keys.pop
      output
    end
  end

  def traverse(hash, keys = [])
    hash.map do |k, v|
      keys.push(k)
      output = if v.is_a?(Hash)
        traverse(v, keys)
      elsif v.is_a?(Array)
        map(v, keys)
      else
        format(v, keys)
      end
      keys.pop
      output
    end.flatten
  end

  def require(key)
    config.require(key)
  end

  def get(key)
    config[key]
  end

  def get_or_ask_for(key)
    config[key] || ask_for(key)
  end

  def ask_for(key)
    $stderr.print "#{key} is required. What should it's value be? "
    answer = $stdin.gets.chomp
    update(key, answer)
    require(key)
  end

  def update(key, value)
    config.update(key, value)
  end

  def delete(key)
    config.delete(key)
  end

  def all
    traverse(config)
  end

  def config
    WAKE_CONFIG
  end
end
