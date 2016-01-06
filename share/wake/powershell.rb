module Wake
  module_function

  def powershell?
    ENV.key?("ISPOWERSHELL")
  end
end
