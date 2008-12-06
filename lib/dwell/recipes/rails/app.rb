Capistrano::Configuration.instance(:must_exist).load do 

  # do this so we can use this method inside the app namespace below
  # as we can't use this method while we're still defining the namespace
  namespace :app do
    def railsmachine_gem?
      top.respond_to?(:apache) and top.apache.respond_to?(:set_apache_conf)
    end
  end
  
  namespace :app do
    
    # lets not overwrite rails machine - try and be compatible
    unless top.app.railsmachine_gem?
    
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
          top.dwell.apache.copy_certs
        end
      end
      
    end
  end
  
  namespace :deploy do
    
    set :known_hosts, []
    
    after "deploy:setup" do
      fix_permissions
      top.dwell.rails.setup_deploy_keys
    end

    task :fix_permissions do
      sudo "chown -R #{user}:admin #{deploy_to}"
    end
    
    # lets not overwrite rails machine - try and be compatible
    unless top.app.railsmachine_gem?
        
      puts "restart your rails app"
      task :restart do
        run "touch #{current_path}/tmp/restart.txt"
      end

      [:start, :stop].each do |t|
        desc "The :#{t} task has no effect when using Passenger as your application server."
        task t, :roles => :app do
          puts "The :#{t} task has no effect when using Passenger as your application server."
        end
      end
    
      # pulled from Capistrano and enhanced with gem installs
      desc "cold app deploy that does gem installs as well"
      task :cold do
        update
        top.dwell.rails.install_app_gems
        migrate
        top.dwell.apache.reload
      end
    
    end
    
  end
end
