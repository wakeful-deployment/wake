class DockerImage
  def initialize(org:, app:, process:, rev:)
    @org = org
    @app = app
    @process = process
    @rev = rev
  end

  def name
    name = if @app == @process
             @app
           else
             "#{@app}-#{process}"
           end

    "#{@org}/wake-#{name}:#{@rev}"
  end

  def to_hash
    {
      org: @org,
      app: @app,
      process: @process,
      rev: @rev,
      name: name
    }
  end
end
