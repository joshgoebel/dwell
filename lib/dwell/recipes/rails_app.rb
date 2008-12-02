Capistrano::Configuration.instance(:must_exist).load do 
  namespace :deploy do
    
    after "deploy:setup" do
      fix_permissions
    end
    
    task :fix_permissions do
      sudo "chown #{user}:admin #{deploy_to}"
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
