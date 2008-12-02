Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :mysql do
  
      desc "Install MySQL5"
      task :install, :roles => :db do
        sudo "DEBCONF_TERSE='yes' DEBIAN_PRIORITY='critical' DEBIAN_FRONTEND=noninteractive apt-get install -qyu --force-yes mysql-server mysql-client libmysqlclient15-dev"
        dwell1.record_install "mysql5"
      end
      
      # Control
      
      desc "Start Mysql"
      task :start, :roles => :db do
        sudo "/etc/init.d/mysql start"
      end
      
      desc "Stop Mysql"
      task :stop, :roles => :db do
        sudo "/etc/init.d/mysql stop"
      end
      
      desc "Restart Mysql"
      task :restart, :roles => :db do
        sudo "/etc/init.d/mysql restart"
      end
      
      desc "Reload Mysql"
      task :reload, :roles => :db do
        sudo "/etc/init.d/mysql reload"
      end
      
      # database operations
      # TODO: should this be dwell:app:db namespace or something?
      
      namespace :db do
        
        desc "dump database" 
        task :dump, :roles => :db, :only => { :primary => true } do
          read_config
          run "cd #{deploy_to} && mysqldump --add-drop-table #{db_name } -u#{db_user} -p#{db_password} > dump_#{short_date}.sql"
        end
        
        desc "fetch dumped database"
        task :fetch, :roles => :db, :only => { :primary => true } do
          run "gzip #{deploy_to}/dump_#{short_date}.sql"
          get "#{deploy_to}/dump_#{short_date}.sql.gz", "dump_#{short_date}.sql.gz"
          `gunzip dump_#{short_date}.sql.gz`
        end
        
        desc "push the local dump to the remote"
        task :push, :roles => :db, :only => { :primary => true } do
          `gzip dump_#{short_date}.sql`
          upload "dump_#{short_date}.sql.gz", "#{deploy_to}/dump_#{short_date}.sql.gz"
          run "gunzip #{deploy_to}/dump_#{short_date}.sql.gz"
        end
        
        task :dump_and_fetch, :roles => :db, :only => { :primary => true } do
          dump
          fetch
        end
                
        def short_date
          Date.today.strftime("%m-%d-%y")
        end
        
        def read_config
          db_config = YAML.load_file('config/database.yml')
          set :db_user, db_config[rails_env]["username"]
          set :db_password, db_config[rails_env]["password"] 
          set :db_name, db_config[rails_env]["database"]
        end
        
      end

    end
  end
end