require 'optparse'
require_relative 'panic'

class OptsParser
  def self.parse(&blk)
    new(&blk).tap {|p| p.parse!}
  end

  def initialize
    @received = []
    @required = []
    @optional = []
    @boolean  = []
    @subcommands = []
    @options  = {}
    @parser   = OptionParser.new
    yield self
  end

  def subcommand(name, file)
    @subcommands << [name, file]
  end

  def banner=(banner)
    @parser.banner = banner
  end

  def []=(key, value)
    @options[key] = value
  end

  def [](key)
    @options[key]
  end

  def optional(short_name = nil, name, description, &blk)
    validate_short_name(short_name)
    @optional << name

    args = ["--#{name} [OPTIONAL]", description]
    args.unshift("-#{short_name}") if short_name
    on(name, args, &blk)
  end

  def boolean(short_name = nil, name, description, &blk)
    validate_short_name(short_name)
    @boolean << name

    args = ["--[no-]#{name}", description]
    args.unshift("-#{short_name}") if short_name
    on(name, args, &blk)
  end

  def required(short_name = nil, name, description, &blk)
    validate_short_name(short_name)
    @required << name

    args = ["--#{name} REQUIRED", description]
    args.unshift("-#{short_name}#{name.upcase}") if short_name
    on(name, args, &blk)
  end

  def on(name, args, &blk)
    @parser.on(*args) do |o|
      @received << name
      self[name] = o
      blk.call(o) if blk
    end
  end

  def parse!
    if subcommand = fetch_subcommand
      execute_subcommand(subcommand)
    end

    if @received.none? && @subcommands.any?
      subcommand_names = @subcommands.map{|sc| sc.first }
      panic! "missing required subcommands: #{subcommand_names.join(",")}"
    end

    perform_top_level_parse!
  end

  def perform_top_level_parse!
    @parser.parse!

    missing_keys = @required - @received

    if missing_keys.any?
      panic! "missing required flag: #{missing_keys.first}\n#{@parser}"
    end

    @boolean.each do |name|
      self[name] = !!self[name]
    end
  rescue OptionParser::MissingArgument, OptionParser::InvalidOption
    panic! "#{$!}\n#{@parser}"
  end

  def execute_subcommand(command)
    file = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "libexec", command))
    cmd = "#{file} #{ARGV.drop(1).join(" ")}"

    exec cmd
    exit(0)
  end

  def fetch_subcommand
    name, file = (name = ARGV.first) &&
      !name.match(/^-/) &&
      @subcommands.find{|sc| sc.first == name.to_sym}
    file
  end

  def validate_short_name(short_name)
    if short_name && short_name.length != 1
      panic! "'#{short_name}' is not the right size. Option short names must only be one character long."
    end
  end
end
