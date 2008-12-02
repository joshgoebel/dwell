Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :passenger do
  
      desc "Enable Passenger"
      task :enable_passenger do
        input = "\n"
        run "sudo passenger-install-apache2-module" do |ch,stream,out|  
          next if out.chomp == input.chomp || out.chomp == ''  
          print out  
          ch.send_data(input) if out =~ /enter/i  
        end
        cfg =<<-EOF
LoadModule passenger_module /usr/lib/ruby/gems/1.8/gems/passenger-2.0.3/ext/apache2/mod_passenger.so
PassengerRoot /usr/lib/ruby/gems/1.8/gems/passenger-2.0.3
PassengerRuby /usr/bin/ruby1.8
        EOF
        put cfg, "/tmp/passenger"
        sudo "mv /tmp/passenger /etc/apache2/conf.d/passenger"
        dwell1.record_install "apache2_mod_passenger"
      end
  
      desc "Setup vhost"
      task :setup_vhost do
        cfg =<<-EOF
ServerName #{domain}
# ServerAlias #{application}.agilebox.com
DocumentRoot #{deploy_to}/public
        EOF
        put cfg, "/tmp/vhost"
        sudo "mv /tmp/vhost /etc/apache2/sites-available/#{application}"
        sudo "a2dissite default"
        sudo "a2ensite #{application}"
      end
  
      desc "Install Passenger"
      task :install do
        enable_passenger
        setup_vhost
      end
  
    end
  end
end