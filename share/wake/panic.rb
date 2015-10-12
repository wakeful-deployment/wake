PanicError = Class.new(Exception)

module Kernel
  def panic!(msg)
    Wake.error msg
    fail PanicError
    exit 1
  end
end
