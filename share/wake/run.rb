require 'open3'
require_relative '../wake'
require_relative 'panic'

module Kernel
  def run(cmd, streamer = nil, log: false)
    Wake.log cmd
    Open3.popen3(cmd) do |i, o, e, t|
      out = ""
      err = ""

      out_thread = Thread.new do
        while stdout = o.read(1)
          if stdout
            if Wake.verbose? || log
              $stdout.print stdout
              $stdout.flush
            end
            out << stdout
          end
        end
      end

      err_thread = Thread.new do
        while stderr = e.read(1)
          if stderr
            if Wake.verbose? || log
              $stderr.print stderr
              $stderr.flush
            end
            err << stderr
          end
        end
      end

      out_thread.join
      err_thread.join

      [out, err, t.value]
    end
  end

  def run!(cmd, *args, **opts)
    out, err, code = run(cmd, *args, **opts)

    unless code.success?
      error_string = ""

      unless out.nil? || out.empty?
        error_string << out
      end

      unless err.nil? || err.empty?
        error_string << err
      end

      panic! "`#{cmd}` failed:\n#{error_string}"
    end

    [out,err]
  end
end
