require 'open3'
require_relative 'panic'

module Kernel
  def run(cmd, verbose = false)
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      out, err = [[], []]
      while (stdout = stdout.gets) || (stderr = stderr.gets)
        puts stdout if verbose && stdout
        puts stderr if verbose && stderr
        out << stdout if stdout
        err << stderr if stderr
      end

      exit_code = wait_thr.value
      [out, err, exit_code]
    end
  end

  def run!(cmd, verbose = false)
    out, err, code = run(cmd, verbose)

    unless code.success?
      panic! "`#{cmd}` failed"
    end

    [out,err]
  end
end
