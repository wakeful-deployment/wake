module Wake
  class Consul
    def initialize(cluster)
      @cluster = cluster
    end

    def curl(url, opts = nil)
      "curl -q #{opts} \"http://localhost:8500/v1#{url}\""
    end

    def run(string)
      @cluster.ssh_proxy.run! string
    end

    def services
      run curl("/catalog/services")
    end

    def service_info(service)
      run curl("/catalog/service/#{service}")
    end

    def nodes
      run curl("/catalog/nodes")
    end

    def node_info(node)
      run curl("/catalog/node/#{node}")
    end

    def put(key, value)
      run curl("/kv/#{key}", "-XPUT -d '#{value}'")
    end

    def get(key)
      run curl("/kv/#{key}")
    end

    def delete(key)
      run curl("/kv/#{key}", "-XDELETE")
    end

    alias_method :del, :delete
  end
end
