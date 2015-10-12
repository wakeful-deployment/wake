require_relative '../wake'
require_relative 'config'
require_relative 'cluster'
require_relative 'azure/token_provider'
require_relative 'azure/actions'
require_relative 'azure/models'

module Azure
  module_function

  LOCATIONS = %w(
    westus
    eastus
    southcentralus
    centralus
    northcentralus
    westeurope
    northeurope
    eastasia
    southeastasia
    japaneast
    japanwest
    australiaeast
    australiasoutheast
    chinaeast
    chinanorth
  ).freeze

  def locations
    LOCATIONS
  end

  def tenant_id
    @tenant_id       ||= WakeConfig.get_or_ask_for("azure.account.tenant_id")
  end

  def client_id
    @client_id       ||= WakeConfig.get_or_ask_for("azure.account.client_id")
  end

  def secret
    @secret          ||= WakeConfig.get_or_ask_for("azure.account.secret")
  end

  def subscription_id
    @subscription_id ||= WakeConfig.get_or_ask_for("azure.account.subscription_id")
  end

  def token_provider
    @token_provider  ||= Azure::TokenProvider.new(tenant_id: tenant_id, client_id: client_id, client_secret: secret)
  end

  def subscription
    @subscription    ||= Azure::Subscription.new(id: subscription_id)
  end
end
