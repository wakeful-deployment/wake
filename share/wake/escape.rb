require 'shellwords'
require_relative 'powershell'

module Wake
  module_function

  private def escape_spaces!(string)
    string.replace "\"#{string}\""
  end

  private def escape_double_quotes!(string)
    string.gsub!(/"/) { "\"\"" }
    string.replace "\"#{string}\""
  end

  private def escape_single_quotes!(string)
    string.gsub!(/'/) { "''" }
    string.replace "\"#{string}\""
  end

  private def escape_powershell(string)
    string = string.to_s.dup # mutate a copy

    if string.include? ?"
      escape_double_quotes! string
    elsif string.include? ?'
      escape_single_quotes! string
    elsif string.include? ?\s
      escape_spaces! string
    end

    string
  end

  def escape(string)
    if Wake.powershell?
      escape_powershell(string)
    else
      Shellwords.escape(string)
    end
  end
end
