module Docker
  class Image
    attr_reader :repo, :rev, :org

    def self.docker_hub_organization
      WakeConfig.get_or_ask_for("docker.hub.organization")
    end

    def initialize(repo:, rev: "latest", org: self.class.docker_hub_organization)
      @repo = repo
      @rev = rev
      @org = org
    end

    def to_s
      "#{org}/#{repo}:#{rev}"
    end

    def self.new_from_string(string)
      org, other = string.split("/")
      repo, rev = other.split(":")

      opts = {
        repo: repo
      }

      opts.merge!(rev: rev) if rev
      opts.merge!(org: org) if org

      new(**opts)
    end
  end

end
