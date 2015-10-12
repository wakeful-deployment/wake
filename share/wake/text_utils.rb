class String
  def columnize
    columnBoundary = lines.map{|line| line.split[0].length}.max
    lines.map do |line|
      tokens = line.split
      "%-#{columnBoundary}s %s\n" %[tokens[0], tokens[1]]
    end.join
  end

  def indent(amount)
    lines.map do |line|
      spaces = " " * amount
      "#{spaces}#{line}"
    end.join
  end
end

