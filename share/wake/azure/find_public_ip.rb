module Azure
  NoPublicIPFound = Class.new(StandardError)

  class FindPublicIP
    attr_reader :vm, :ip

    def initialize(vm:)
      @vm = vm
    end

    def fetch_vm
      Azure.resources.vms.get!(vm).response.parsed_body
    end

    def extract_nic
      nics = fetch_vm["properties"]["networkProfile"]["networkInterfaces"]

      if nics.nil? || nics.empty?
        fail NoPublicIPFound
      else
        nic = nics.first
        nic_name = nic["name"]
        Azure::NIC.new(resource_group: vm.resource_group, name: nic_name)
      end
    end

    def fetch_nic
      Azure.resources.nics.get!(extract_nic).response.parsed_body
    end

    def extract_ip
      ip_configs = fetch_nic["properties"]["ipConfigurations"]

      if ip_configs.nil? || ip_configs.empty?
        fail NoPublicIPFound
      else
        ip_config = ip_configs.first
        public_ip = ip_config["properties"]["publicIPAddress"]

        if public_ip
          ip_id = public_ip["id"]
          ip_name = ip_id.split("/").last
          Azure::PublicIP.new(resource_group: vm.resource_group, name: ip_name)
        else
          fail NoPublicIPFound
        end
      end
    end

    def fetch_ip
      Azure.resources.public_ips.get!(extract_ip).response.parsed_body
    end

    def call
      @ip = fetch_ip["properties"]["ipAddress"]
    end

    def self.call(**opts)
      new(**opts).tap { |f| f.call }
    end
  end
end
