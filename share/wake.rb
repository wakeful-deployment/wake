require 'shellwords'
require_relative 'wake/root'

def wake(*args)
  formatted_args = args.map { |a| Shellwords.escape(a) }

  formatted_args << "--verbose" if Wake.verbose?
  formatted_args << "--very-verbose" if Wake.very_verbose?

  if formatted_args.any?(&:nil?)
    fail "provided a nil argument to a wake shell command: #{formatted_args.inspect}"
  end

  formatted_string = formatted_args.join(" ")

  Wake.log "$ wake #{formatted_string}"

  system "#{WAKE_ROOT}/bin/wake #{formatted_string}"

  unless $?.success?
    fail "exited with status #{$?.exitstatus}"
  end
end

module Wake
  def self.verbose
    !!@verbose
  end

  def self.very_verbose
    !!@very_verbose
  end

  def self.verbose=(value)
    @verbose = value
  end

  def self.very_verbose=(value)
    @verbose ||= @very_verbose = value
  end

  class << self
    alias_method :verbose?, :verbose
    alias_method :very_verbose?, :very_verbose
  end

  def self.output(msg, io: $stdout)
    if String === msg
      io.puts msg
    else
      io.puts msg.inspect
    end
  end

  def self.log(msg)
    if verbose?
      output msg
    end
  end

  def self.debug(msg)
    if very_verbose?
      output msg
    end
  end

  def self.error(msg)
    msg = "** Error: #{msg}"
    output msg, io: $stderr
  end
end
