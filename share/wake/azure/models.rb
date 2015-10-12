Dir[File.expand_path("../models/*rb", __FILE__)].each do |f|
  require_relative f
end
