Capistrano::Configuration.instance(:must_exist).load do 
  namespace :deploy do
    
    after "deploy:setup" do
      fix_permissions
    end
    
    task :setup_keys do
      if File.exist?("config/ssh/deploy_keys/#{user}")
        put File.read("config/ssh/deploy_keys/#{user}"), "/home/#{user}/.ssh/id_rsa", :mode => 0600
        sudo "chown #{user}.admin /home/#{user}/.ssh/id_rsa"
        put File.read("config/ssh/deploy_keys/#{user}.pub"), "/home/#{user}/.ssh/id_rsa.pub", :mode => 0600
        sudo "chown #{user}.admin /home/#{user}/.ssh/id_rsa.pub"
        put File.read("config/ssh/known_hosts"), "/home/#{user}/.ssh/known_hosts", :mode => 0600
        sudo "chown #{user}.admin /home/#{user}/.ssh/known_hosts"
      end
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
    
    task :fix_permissions do
      sudo "chown -R #{user}:admin #{deploy_to}"
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
        top.dwell.passenger.setup_vhost
#        reload
      end
      
      # %w{reload start stop restart}.each do |command|
      #   desc "#{command} the web server"
      #   task command.to_sym do
      #     top.dwell.apache.send command.clone
      #   end
      # end
        
    end
  end
end
