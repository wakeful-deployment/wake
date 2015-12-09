require_relative "command"
require_relative "../../scp"
require 'resolv'

module Wake
  module Commands
    class DNSMasqConf < Command
      def call(*ns_servers)
        ips = ns_servers.map { |s| Resolv.getaddress(s) }

        write_and_copy "dnsmasq.conf", render("dnsmasq.conf.erb", ips: ips)
      end
    end
  end
end
