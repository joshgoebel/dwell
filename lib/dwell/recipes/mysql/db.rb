Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :mysql do

      set :mysql_admin, "root"

      # database operations
      # TODO: should this be dwell:app:db namespace or something?
      namespace :db do
  
        desc "Create MySQL database and user based on config/database.yml"
        task :create, :roles => :db, :only => { :primary => true } do

          set_mysql_admin
          read_config

          sql = "CREATE DATABASE IF NOT EXISTS #{db_name};"
          sql += "GRANT ALL PRIVILEGES ON #{db_name}.* TO #{db_user}@localhost IDENTIFIED BY '#{db_password}';"  
          mysql_helper.execute sql, mysql_admin
        end

        def set_mysql_admin
          set :mysql_admin, user unless mysql_admin
        end

        desc "dump database" 
        task :dump, :roles => :db, :only => { :primary => true } do
          read_config
          dwell1.run_with_input "cd #{deploy_to} && mysqldump --add-drop-table #{db_name } -u#{db_user} -p > dump_#{short_date}.sql", /password/i, db_password
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
        
        desc "import the database into the remote"
        task :import, :roles => :db, :only => { :primary => true } do
          read_config
          dwell1.run_with_input "mysql #{db_name} -u#{db_user} -p < #{deploy_to}/dump_#{short_date}.sql", /password/i, db_password
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

