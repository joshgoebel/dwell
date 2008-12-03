Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :apache do

      set :apache_server_name, nil
      # set :apache_conf, nil
      set :apache_default_vhost, false
      set :apache_ctl, "/etc/init.d/apache2"
      set :apache_server_aliases, []
      # set :apache_proxy_port, 8000
      # set :apache_proxy_servers, 2
      # set :apache_proxy_address, "127.0.0.1"
      set :apache_ssl_enabled, false
      set :apache_ssl_ip, nil
      set :apache_ssl_forward_all, false

      desc "Install Apache"  
      task :install do
        sudo "apt-get install apache2 apache2-threaded-dev -y"
        dwell1.record_install "apache2"
      end

      desc "Setup vhost"
      task :setup_vhost do
        set :apache_server_name, domain unless apache_server_name
        server_aliases = []
        server_aliases << "www.#{apache_server_name}" unless apache_server_name =~ /^www\./
        server_aliases.concat apache_server_aliases
        set :apache_server_aliases_array, server_aliases        
        
        file = File.join(File.dirname(__FILE__), "../templates", "vhost.conf")
        template = File.read(file)
        buffer = ERB.new(template).result(binding)
        put buffer, "/tmp/vhost"
        sudo "mv /tmp/vhost /etc/apache2/sites-available/#{application}"
        sudo "a2dissite default"
        sudo "a2ensite #{application}"
        # enable some modules we need
        sudo "a2enmod rewrite"
      end
  
      # Control
      
      desc "Start Apache"
      task :start, :roles => :web do
        sudo "#{apache_ctl} start"
      end
      
      desc "Stop Apache"
      task :stop, :roles => :web do
        sudo "#{apache_ctl} stop"
      end
      
      desc "Restart Apache"
      task :restart, :roles => :web do
        sudo "#{apache_ctl} restart"
      end
      
      desc "Reload Apache"
      task :reload, :roles => :web do
        sudo "#{apache_ctl} reload"
      end
  
  
    end
  end
end