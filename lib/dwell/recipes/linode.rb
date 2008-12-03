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
      end

    end
  end
end