module Docker
  class Application
    attr_reader :name, :process

    def initialize(name:, process:)
      @name = name
      @process = process
    end

    def unique_name
      if @app == @process
        @app
      else
        "#{@app}-#{@process}"
      end
    end

    def image_name
      "wake-#{unique_name}"
    end
  end
end
