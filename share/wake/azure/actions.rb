Dir[File.expand_path("../actions/*.rb", __FILE__)].each do |f|
  require_relative f
end
