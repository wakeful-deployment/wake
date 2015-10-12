require 'uri'
require_relative '../model'

module Azure
  class Subscription
    include Model

    required :id

    uri { URI("/subscriptions/#{id}") }
  end
end
