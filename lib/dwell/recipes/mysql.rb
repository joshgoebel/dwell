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

    end
  end
end