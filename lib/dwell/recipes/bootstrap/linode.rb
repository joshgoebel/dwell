Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :linode do

      task :create_deploy_user do
        dwell1.adduser deploy_user, :group => "admin"
        new_password = Capistrano::CLI.ui.ask("Enter password for #{deploy_user}:") { |q| q.echo = true }
        dwell1.invoke_with_input("passwd #{deploy_user}", /UNIX password/, new_password)
      end
      
      task :copy_ssh_key do
        dwell1.mkdir "/home/#{deploy_user}/.ssh", :mode => 0700, :owner => "#{deploy_user}.admin"
        put File.read("config/dwell/authorized_keys/#{deploy_user}"), "/home/#{deploy_user}/.ssh/authorized_keys", :mode => 0600
        sudo "chown #{deploy_user}.admin /home/#{deploy_user}/.ssh/authorized_keys"
      end
      
      task :disable_root_login do
        dwell1.config_gsub "/etc/ssh/sshd_config", /^PermitRootLogin (.*)$/,"PermitRootLogin no" 
        sudo "/etc/init.d/ssh reload"
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
      
      task :setup_hostname do
        hostname=ENV["HOSTS"]
        sudo "echo #{hostname} > /tmp/hostname"
        sudo "mv /tmp/hostname /etc/hostname"
        sudo "chown root:root /etc/hostname"
        host_line="#{get_ip_info.first} #{hostname.split(".").first} #{hostname}"
        dwell1.append_to_file_if_missing("/etc/hosts",host_line)
        sudo "hostname --file /etc/hostname"
      end
      
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
      
      desc "bootstrap linode box"
      task :bootstrap do
        hostname=ENV["HOSTS"]
        if hostname =~ /\d+\.\d+\.\d+\.\d+/
          puts "You used an IP, please use the hostname so can set /etc/hostname on the remote."
          exit
        end
        if hostname.nil? or hostname.empty?
          puts "You must specify HOSTS='hostname' to use the bootstrap command."
          exit
        end
        set :deploy_user, user
        auth_keys="config/dwell/authorized_keys/#{deploy_user}"
        unless File.exist?(auth_keys)
          puts "\n    Please place authorized SSH keys for #{deploy_user} in:"
          puts "      #{auth_keys}\n\n"
          exit
        end
        set :user, "root"
        if ubuntu1.lsb_info[:distrib_codename]=="intrepid"
          # for linode's slimmed down intrepid
          run "addgroup admin"
          dwell1.append_to_file_if_missing "/etc/sudoers", "%admin ALL=(ALL) ALL"
          sudo "apt-get install ubuntu-standard -y" 
        end
        create_deploy_user
        copy_ssh_key
        set :user, deploy_user        
        # test deploy login via ssh before we disable root login
        sudo "echo"
        disable_root_login
        setup_hostname
        setup_static_ip
      end

    end
  end
end