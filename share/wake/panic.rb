module Kernel
  def panic!(msg)
    Wake.error msg
    exit 1
  end
end
