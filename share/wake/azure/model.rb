module Azure
  module SubResource
    def self.included(base)
      base.include Model

      base.instance_exec do
        required :name
        optional :location, default: ->{ parent.location }
      end
    end
  end

  module Model
    MissingParent = Class.new(StandardError)

    module ClassMethods
      def attributes
        @attributes ||= []
      end

      def required_attributes
        @required_attributes ||= []
      end

      def validations
        @validations ||= []
      end

      def defaults
        @defaults ||= {}
      end

      def required(name)
        required_attributes << name
        optional name
      end

      def parent(name = nil)
        if name.nil?
          @parent
        else
          @parent = name
          required name
        end
      end

      def boolean(name, default: false)
        optional name, default: default
      end

      def optional(name, default: nil)
        attributes << name
        defaults[name] = default.freeze
        attr_reader name
      end

      def uri(&blk)
        define_method(:uri, &blk)
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    def parent
      if self.class.parent.nil?
        fail MissingParent
      else
        send(self.class.parent)
      end
    end

    def initialize(**opts)
      self.class.attributes.each do |name|
        value = opts.delete(name)
        instance_variable_set(:"@#{name}", value)
      end

      defaults = opts.delete(:defaults)
      defaults = true if defaults.nil?

      if opts.key?(:parent)
        if self.class.parent.nil?
          fail MissingParent, "::parent is not set on the class, cannot provide :parent argument during initialize"
        end

        value = opts.delete(:parent)
        instance_variable_set(:"@#{self.class.parent}", value)
      end

      unless opts.empty?
        fail ArgumentError, "too many arguments, #{opts.keys.inspect} not allowed"
      end

      if self.class.parent && parent.nil?
        fail MissingParent, "must provide the parent '#{self.class.parent}' as a keyword argument"
      end

      if defaults
        defaults!
      end
    end

    def defaults!
      self.class.defaults.each do |name, default|
        var_name = :"@#{name}"

        next if instance_variable_get(var_name)

        processed_default = if Proc === default
          if default.arity == 0
            instance_exec(&default)
          else
            default.call(self)
          end
        else
          default
        end

        instance_variable_set(var_name, processed_default)
      end
    end

    def valid?
      values = self.class.required_attributes.map do |name|
        instance_variable_get(:"@#{name}")
      end

      not values.any?(&:nil?)
    end

    def invalid?
      !!valid?
    end
  end
end
