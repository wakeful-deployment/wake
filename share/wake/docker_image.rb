class DockerImage
  def initialize(org:, app:, process:, rev:, release: false)
    @org = org
    @app = app
    @process = process
    @rev = rev
    @release = release
  end

  def unique_name
    if @app == @process
      @app
    else
      "#{@app}-#{@process}"
    end
  end

  def name
    "#{@org}/wake-#{unique_name}:#{@rev}"
  end

  def release_name
    "#{@org}/wake-#{unique_name}-release:#{@rev}"
  end

  def latest
    "#{@org}/wake-#{unique_name}:latest"
  end

  def to_hash
    hash = {
      org: @org,
      app: @app,
      process: @process,
      rev: @rev,
      name: name
    }

    hash.merge!(release_name: release_name) if @release

    hash
  end
end
