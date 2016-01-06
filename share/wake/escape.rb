require_relative 'powershell'

module Wake
  module_function

  def escape_char
    if Wake.powershell?
      ?`
    else
      ?\\
    end
  end

  private def escape_spaces!(string)
    if Wake.powershell?
      string.replace "\"#{string}\""
    else
      string.gsub!(/\s/) { "#{escape_char}\s" }
    end
  end

  private def escape_double_quotes!(string)
    string.gsub!(/"/) { "#{escape_char}\"" }
    string.replace "\"#{string}\""
  end

  private def escape_single_quotes!(string)
    string.gsub!(/'/) { "#{escape_char}'" }
    string.replace "'#{string}'"
  end

  # If string has double quotes, then escape any inner quotes and surround with double quotes
  # Else if string has spaces, then either escape the spaces or surround with double quotes
  # Else just leave it alone
  #
  # so:
  #   "revision"                    => "revision"
  #   "foo bar"                     => "foo\\ bar"                          || "\"foo bar\"" for windows
  #   "something \"else\" in here"  => "\"something \\\"else\\\" in here\"" || "\"something `\"else`\" in here" for windows
  def escape(string)
    string = string.dup # mutate a copy

    if string.include? ?"
      escape_double_quotes! string
    elsif string.include? ?'
      escape_single_quotes! string
    elsif string.include? ?\s
      escape_spaces! string
    end

    string
  end
end
