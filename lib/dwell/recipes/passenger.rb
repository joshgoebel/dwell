require 'erb'
Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :passenger do
        
      desc "Enable Passenger"
      task :enable_passenger do
        input = "\n"
        dwell1.sudo_with_input "passenger-install-apache2-module", /enter/i, "\n"
        cfg =<<-EOF
LoadModule passenger_module /usr/lib/ruby/gems/1.8/gems/passenger-2.0.4/ext/apache2/mod_passenger.so
PassengerRoot /usr/lib/ruby/gems/1.8/gems/passenger-2.0.4
PassengerRuby /usr/bin/ruby1.8
        EOF
        put cfg, "/tmp/passenger"
        sudo "mv /tmp/passenger /etc/apache2/conf.d/passenger"
        dwell1.record_install "apache2_mod_passenger"
      end
  
      desc "Install Passenger"
      task :install do
        enable_passenger
#        setup_vhost
      end
  
    end
  end
end