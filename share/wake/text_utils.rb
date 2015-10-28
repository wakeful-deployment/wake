module TextUtils
  module_function

  def columnize(text)
    columnBoundary = text.map{|line| line.split[0].length}.max
    text.map do |line|
      tokens = line.split 
      "%-#{columnBoundary}s %s\n" %[tokens[0], tokens[1]]
    end
  end

  def sort(text)
    text.sort
  end
end
