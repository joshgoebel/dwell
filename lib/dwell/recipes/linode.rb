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
      
      desc "setup static ip address" 
      task :setup_static_ip do
        ip,broadcast,mask,gateway=nil
        run "/sbin/ifconfig eth0" do |channel, stream, data|
          if data.match(/inet addr:([^ ]*)  Bcast:([^ ]*)  Mask:([^ ]*)/)
            ip, broadcast, mask = $1, $2, $3
          end
        end
        run "ip route" do |channel, stream, data|
          gateway=$1 if data.match(/default via ([^ ]*) dev eth0/)
        end

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
          sudo "kill -9 `cat /var/run/dhclient.eth0.pid`"
      end
      
      desc "bootstrap linode box"
      task :bootstrap do
        set :deploy_user, user
        auth_keys="config/dwell/authorized_keys/#{deploy_user}"
        unless File.exist?(auth_keys)
          puts "\n    Please place authorized SSH keys for #{deploy_user} in:"
          puts "      #{auth_keys}\n\n"
          exit
        end
        set :user, "root"
        create_deploy_user
        copy_ssh_key
        set :user, deploy_user        
        # test deploy login via ssh before we disable root login
        sudo "echo"
        disable_root_login
        setup_static_ip
      end

    end
  end
end