require 'open3'

module TextUtils
  module_function

  def columnize(text)
    Open3.popen3("column -t") do |stdin, stdout, stderr, wait_thr|
      stdin.puts text
      stdin.close

      if wait_thr.value.success?
        stdout.read.chomp
      else
        text
      end
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
