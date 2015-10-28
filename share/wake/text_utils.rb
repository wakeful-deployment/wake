require 'open3'

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
    Open3.popen3("sort") do |stdin, stdout, stderr, wait_thr|
      stdin.puts text
      stdin.close

      if wait_thr.value.success?
        stdout.read.chomp
      else
        text
      end
    end
  end
end
