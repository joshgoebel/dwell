Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :apache do

      desc "Install Apache"  
      task :install do
        sudo "apt-get install apache2 apache2-threaded-dev -y"
        dwell1.record_install "apache2"
      end
  
      # Control
      
      desc "Start Apache"
      task :start, :roles => :web do
        sudo "/etc/init.d/apache2 start"
      end
      
      desc "Stop Apache"
      task :stop, :roles => :web do
        sudo "/etc/init.d/apache2 stop"
      end
      
      desc "Restart Apache"
      task :restart, :roles => :web do
        sudo "/etc/init.d/apache2 restart"
      end
      
      desc "Reload Apache"
      task :reload, :roles => :web do
        sudo "/etc/init.d/apache2 reload"
      end
  
  
    end
  end
end