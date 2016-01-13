require_relative "powershell"

module Wake
  module_function

  def exec(command)
    if Wake.powershell?
      system command
      exit $?.exitstatus
    else
      Kernel.exec command
    end
  end
end
