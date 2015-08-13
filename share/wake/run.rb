require 'open3'
require_relative 'panic'

module Kernel
  def run(cmd, verbose = false)
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      out, err = [[], []]
      while line = stdout.gets
        puts line if verbose
        out << line
      end
      while line = stderr.gets
        puts line if verbose
        err << line
      end

      exit_code = wait_thr.value
      [out, err, exit_code]
    end
  end

  def run!(cmd, verbose = false)
    if verbose
      system cmd
    else
      `#{cmd}`
    end

    unless $?.success?
      panic! "`#{cmd}` failed"
    end
  end
end
