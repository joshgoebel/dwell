Capistrano::Configuration.instance(:must_exist).load do 
  namespace :deploy do
    
    set :known_hosts, []
    
    after "deploy:setup" do
      fix_permissions
      setup_deploy_keys
    end
    
    puts "restart your rails app"
    task :restart do
      run "touch #{current_path}/tmp/restart.txt"
    end

    task :stop do
      puts "NOTE: You can't really start and stop a passenger app, try 'restart'."
    end

    task :start do
      puts "NOTE: You can't really start and stop a passenger app, try 'restart'."
    end    

    task :fix_permissions do
      sudo "chown -R #{user}:admin #{deploy_to}"
    end
    
    task :setup_deploy_keys do
      if File.exist?("config/dwell/deploy_keys/#{user}")
        put File.read("config/dwell/deploy_keys/#{user}"), "/home/#{user}/.ssh/id_rsa", :mode => 0600
        sudo "chown #{user}.admin /home/#{user}/.ssh/id_rsa"
        put File.read("config/dwell/deploy_keys/#{user}.pub"), "/home/#{user}/.ssh/id_rsa.pub", :mode => 0600
        sudo "chown #{user}.admin /home/#{user}/.ssh/id_rsa.pub"
      end
      known_hosts.each do |host|
        key=File.open("#{File.dirname(__FILE__)}/../known_hosts/#{host}").read
        dwell1.append_to_file_if_missing("/home/#{user}/.ssh/known_hosts", key)
      end
      sudo "chown #{user}.admin /home/#{user}/.ssh/known_hosts"
    end
    
    # pulled from Capistrano and enhanced with gem installs
    desc "cold app deploy that does gem installs as well"
    task :first_time do
      update
      install_app_gems
      migrate
      top.dwell.apache.reload
    end
    
    task :install_app_gems do
      run "grep '^[^#]*config.gem' #{current_path}/config/environment.rb && " +
        "cd #{current_path} && #{sudo} rake gems:install"
    end
    
    namespace :db do
      
      desc "setup the database automatically"
      task :setup do
        top.dwell.mysql.db.create
      end
      
    end
    
    namespace :web do
      
      desc "setup a passenger config for this app"
      task :setup do
        top.dwell.apache.setup_vhost
        copy_certs
      end
      
      task :copy_certs do
        Dir.glob("config/dwell/ssl/*").each do |file|
          basename=File.basename(file)
          dwell1.sudo_upload file, "/etc/ssl/certs/#{basename}" if file=~/.crt/
          if file=~/.key/      
            dwell1.sudo_upload file, "/etc/ssl/private/#{basename}", :mode => 0600, :owner => "root.admin"
          end
        end
      end

    end
  end
end
