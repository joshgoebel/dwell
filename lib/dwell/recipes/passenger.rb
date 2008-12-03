require 'erb'
Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :passenger do
        
      set :passenger_use_global_queue, "off"
      set :passenger_pool_idle_time, 300
      set :passenger_rails_spawn_method, "smart"
      set :passenger_max_instances_per_app, 0
      set :passenger_max_pool_size, 6
        
      desc "Enable Passenger"
      task :enable_passenger do
        input = "\n"
        dwell1.sudo_with_input "passenger-install-apache2-module", /enter/i, "\n"
        dwell1.record_install "apache2_mod_passenger"
      end
      
      task :setup_config do
        file = File.join(File.dirname(__FILE__), "../templates", "passenger.conf")
        template = File.read(file)
        buffer = ERB.new(template).result(binding)
        put buffer, "/tmp/passenger"
        sudo "mv /tmp/passenger /etc/apache2/conf.d/passenger"
      end
  
      desc "Install Passenger"
      task :install do
        enable_passenger
        setup_config
#        setup_vhost
      end
  
    end
  end
end