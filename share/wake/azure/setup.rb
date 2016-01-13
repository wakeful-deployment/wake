require_relative 'setup/seed'
require_relative 'setup/server'
require_relative 'setup/agent'

module Azure
  module Setup
    TYPES = {
      "seed"   => Seed,
      "server" => Server,
      "agent"  => Agent
    }.freeze

    def self.call(**opts)
      klass = TYPES[opts.delete(:type)]
      klass.new(**opts).tap { |k| k.call }
    end
  end
end
