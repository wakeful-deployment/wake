require 'optparse'
require_relative '../wake'
require_relative 'panic'
require_relative 'powershell'
require_relative 'exec'

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

    self.boolean :v, :verbose,        "Run verbosely"
    self.boolean :V, :"very-verbose", "Run very verbosely"
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

  def fetch(key, default = nil)
    if default
      @options.fetch(key, default)
    else
      @options.fetch(key)
    end
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
    if subcommand = fetch_subcommand_file
      execute_subcommand(subcommand)
    end

    if ARGV.include?("-h") || ARGV.include?("--help")
      ARGV.delete("-h")
      ARGV.delete("--help")
      $stderr.puts usage
      exit 1
    end

    if @received.none? && @subcommands.any?
      Wake.error "missing required command"
      $stderr.puts usage
      exit 1
    end

    perform_top_level_parse!

    Wake.verbose      = self[:verbose]
    Wake.very_verbose = self[:"very-verbose"]
  end

  def perform_top_level_parse!
    @parser.parse!

    missing_keys = @required - @received

    if missing_keys.any?
      panic! "missing required flag: #{missing_keys.first}\n#{usage}"
    end

    @boolean.each do |name|
      self[name] = !!self[name] unless self[name].nil?
    end
  rescue OptionParser::MissingArgument, OptionParser::InvalidOption
    panic! "#{$!.message}\n\n#{usage}"
  end

  def execute_subcommand(command)
    file = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "libexec", command))
    cmd = "#{file} #{ARGV.drop(1).join(" ")}"

    if Wake.powershell?
      system "#{ENV["RUBY_EXE_PATH"]} #{cmd}"
      exit $?.exitstatus
    else
      Wake.exec cmd
    end
  end

  def fetch_subcommand
    (name = ARGV.first) &&
      !name.match(/^-/) &&
      @subcommands.find{|sc| sc.first == name.to_sym}
  end

  def fetch_subcommand_file
    _, file = fetch_subcommand
    file
  end

  def usage
    if @subcommands.any?
      subcommands = @subcommands.map{|sc| sc.first}
      "#{@parser}\nAvailable commands:\n* #{subcommands.join("\n* ")}"
    else
      @parser.to_s
    end
  end

  def validate_short_name(short_name)
    if short_name && short_name.length != 1
      panic! "'#{short_name}' is not the right size. Option short names must only be one character long."
    end
  end
end
