require_relative 'action'

module Azure
  class Resource
    def initialize(name, resources:)
      @name = name
      @resources = resources
      @version = nil
    end

    def version(v)
      @version = v
    end

    class RequestFailed < StandardError
      def initialize(action:)
        @action = action
        message = "Request to '#{@action.request.uri}' failed with status '#{@action.response.status}' and body '#{@action.response.body}'"
        super(message)
      end
    end

    def action(name, verb: nil, path: nil, &blk)
      verb ||= name

      if @version.nil?
        fail "version must be set before creating actions"
      end

      name_bang = :"#{name}!"

      define_singleton_method name do |model, poll: true, call: true|
        Action.new(token: @resources.token, model: model, verb: verb, version: @version, path: path, &blk).tap do |action|
          action.call(poll: poll) if call
        end
      end

      define_singleton_method name_bang do |model|
        send(name, model, poll: true, call: true).tap do |a|
          status = a.response.status

          unless status >= 200 && status <= 300
            fail RequestFailed.new(action: a)
          end
        end
      end

      if verb == :get
        def exists?(model)
          status = get(model).response.status

          if status == 200
            true
          elsif status == 404
            false
          else
            fail RequestFailed.new(action: a)
          end
        end
      end
    end
  end
end
