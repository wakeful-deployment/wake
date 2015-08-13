module Kernel
  def panic!(msg)
    $stderr.puts msg
    exit(1)
  end
end
