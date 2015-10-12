module Tempdir
  module_function

  def create
    dir = Dir.mktmpdir
    yield(dir)
  end
end
