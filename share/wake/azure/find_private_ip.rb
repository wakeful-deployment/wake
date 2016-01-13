module Azure
  class FindPrivateIP
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
        fail "vm doesn't have a nic"
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
        fail "nic doesn't have an ip address"
      else
        ip_config = ip_configs.first
        ip_config["properties"]["privateIPAddress"]
      end
    end

    def call
      @ip = extract_ip
    end

    def self.call(**opts)
      new(**opts).tap { |f| f.call }
    end
  end
end
