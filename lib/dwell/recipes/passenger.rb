require 'erb'
Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :passenger do
        
      set :passenger_use_global_queue, "off"
      set :passenger_pool_idle_time, 300
      set :passenger_rails_spawn_method, "smart"
      set :passenger_max_instances_per_app, 0
      set :passenger_max_pool_size, 6
      set :passenger_ruby, "/usr/bin/ruby1.8"
              
      desc "Install Passenger Apache 2 module"
      task :install_passenger_module, :roles => :app do
        dwell1.sudo_with_input "passenger-install-apache2-module", /enter/i, "\n"
        dwell1.record_install "apache2_mod_passenger"
      end
      
      desc "Setup the configuration for mod_massenger"
      task :setup, :roles => :app do
        set :passenger_ruby, "/opt/ruby-enterprise/bin/ruby" if which_ruby==:enterprise
        run "gem list --local | grep passenger" do |channel, stream, data|
          if data.match(/passenger \(([^ ,)]*)/)
            set :passenger_version, $1
          else
            raise "couldn't determine version of passenger gem"
          end
        end
        file = File.join(File.dirname(__FILE__), "../templates", "passenger.conf")
        template = File.read(file)
        buffer = ERB.new(template).result(binding)
        put buffer, "/tmp/passenger"
        puts buffer
        sudo "mv /tmp/passenger /etc/apache2/conf.d/passenger"
      end
  
      desc "Install Passenger"
      task :install, :roles => :app do
        install_passenger_module
        setup
      end
  
    end
  end
end