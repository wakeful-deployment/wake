module Azure
  class ProvisioningStatePoller
    def initialize(max_tries: 300, resource:, model:)
      @model = model
      @resource = resource
      @max_tries = max_tries
      @tries = 0
    end

    def call
      loop do
        result = @resource.get(@model)

        if result.response.status == 200
          body = result.response.parsed_body
          state = body["properties"] && body["properties"]["provisioningState"]

          if state.nil? || state == "Succeeded"
            break
          end
        end

        @tries += 1
        if @tries >= @max_tries
          fail "'#{@model.inspect}' never finished creating"
        end

        sleep 6
      end
    end

    def self.call(**opts)
      new(**opts).tap { |c| c.call }
    end
  end
end
