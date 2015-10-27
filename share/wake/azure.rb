begin
  gem 'azure_mgmt_storage'
  gem 'azure_mgmt_compute'
  gem 'azure_mgmt_resources'
  gem 'azure_mgmt_network'
  require 'azure_mgmt_network'
  require 'azure_mgmt_compute'
  require 'azure_mgmt_resources'
  require 'azure_mgmt_storage'

  include Azure::ARM::Network
  include Azure::ARM::Network::Models
  include Azure::ARM::Compute
  include Azure::ARM::Compute::Models
  include Azure::ARM::Resources
  include Azure::ARM::Resources::Models
  include Azure::ARM::Storage
  include Azure::ARM::Storage::Models
rescue Gem::LoadError
  puts "Please install the azure gems:"
  puts "$ gem install azure_mgmt_storage azure_mgmt_compute azure_mgmt_resources azure_mgmt_network --no-rdoc --no-ri"
  exit 1
end
