Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :linode do

      after "dwell:linode:bootstrap", "dwell:linode:setup_hostname"
      after "dwell:linode:bootstrap", "dwell:linode:setup_static_ip"

      desc "bootstrap a new linode server"
      task :bootstrap do
        hostname=ENV["HOSTS"]
        if hostname =~ /\d+\.\d+\.\d+\.\d+/
          puts "You used an IP, please use the hostname so we can set /etc/hostname on the remote."
          exit
        end
        if hostname.nil? or hostname.empty?
          puts "You must specify HOSTS='hostname' to use the bootstrap command."
          exit
        end
        top.dwell.server.bootstrap
      end

      def get_ip_info
        run "/sbin/ifconfig eth0" do |channel, stream, data|
          if data.match(/inet addr:([^ ]*)  Bcast:([^ ]*)  Mask:([^ ]*)/)
            return $1, $2, $3
          end
        end
      end

      def get_gateway
        run "ip route" do |channel, stream, data|
          return $1 if data.match(/default via ([^ ]*) dev eth0/)
        end
      end

      ## TODO : make multi-server safe
      task :setup_hostname do
        hostname=ENV["HOSTS"]
        sudo "echo #{hostname} > /tmp/hostname"
        sudo "mv /tmp/hostname /etc/hostname"
        sudo "chown root:root /etc/hostname"
        host_line="#{get_ip_info.first} #{hostname.split(".").first} #{hostname}"
        dwell1.append_to_file_if_missing("/etc/hosts",host_line)
        sudo "hostname --file /etc/hostname"
      end

      ## TODO : make multi-server safe
      desc "setup static ip address" 
      task :setup_static_ip do
        ip,broadcast,mask=get_ip_info
        gateway=get_gateway

          interface=<<-EOS
iface eth0 inet static
address #{ip}
netmask #{mask.strip}
broadcast #{broadcast}
gateway #{gateway}
          EOS
          dwell1.config_gsub "/etc/network/interfaces", "iface eth0 inet dhcp", interface
          sudo "chown root:root /etc/network/interfaces"
          sudo "/etc/init.d/networking restart"
          # kill the dhcp client
          sudo "pkill dhclient3"
      end
    end
  end
end