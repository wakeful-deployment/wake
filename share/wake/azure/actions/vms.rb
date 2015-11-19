require_relative '../resources'

module Azure
  setup_resources do
    resources :vms do
      version "2015-06-15"
      action :get
      action :delete
      action :power_off,  verb: :post, path: "/poweroff"
      action :power_on,   verb: :post, path: "/poweron"
      action :generalize, verb: :post, path: "/generalize"
      action :capture,    verb: :post, path: "/capture" do
        def body
          {
            vhdPrefix: "wake",
            destinationContainerName: model.name,
            overwriteVhds: true
          }
        end
      end
      action :put do
        def from_host_image?
          !!model.host_image_uri
        end

        def os_disk_name
          "#{model.name}-os-disk"
        end

        def vhd_uri
          URI("https://#{model.storage_account.name}.blob.core.windows.net/#{model.name}/#{os_disk_name}.vhd")
        end

        def os_disk
          {
            caching: "None",
            name: os_disk_name,
            vhd: {
              uri: vhd_uri
            },
            createOption: "fromImage"
          }.tap do |disk|
            if from_host_image?
              disk.merge!({
                osType: 'Linux',
                image: {
                  uri: model.host_image_uri
                }
              })
            end
          end
        end

        def ubuntu_image_reference
          {
            publisher: "Canonical",
            offer: "UbuntuServer",
            sku: "14.04.2-LTS",
            version: "14.04.201503090"
          }
        end

        def storage_profile
          { osDisk: os_disk }.tap do |profile|
            unless from_host_image?
              profile.merge!({ imageReference: ubuntu_image_reference })
            end
          end
        end

        def public_keys
          if model.ssh_public_key
            [{
              path: model.ssh_key_path,
              keyData: model.ssh_public_key
            }]
          else
            []
          end
        end

        def os_profile
          {
            computerName: model.name,
            adminUsername: model.admin_username,
            adminPassword: model.admin_password,
            linuxConfiguration: {
              disablePasswordAuthentication: false,
              ssh: {
                publicKeys: public_keys
              }
            }
          }
        end

        def network_profile
          {
            networkInterfaces: [{
              id: model.nic.uri.to_s,
              name: model.nic.name,
              properties: {
                primary: true,
              }
            }]
          }
        end

        def body
          {
            location: model.location,
            properties: {
              hardwareProfile: {
                vmSize: model.size
              },
              storageProfile: storage_profile,
              osProfile: os_profile,
              networkProfile: network_profile
            }
          }
        end
      end
    end
  end
end

