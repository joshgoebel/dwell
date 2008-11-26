Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :passenger do
  
      # desc "Enable GPM"
      # task :enable_gpm do
      #   sudo "apt-get install gpm"
      # end
  
      desc "Enable Passenger"
      task :enable_passenger do
        input = ''
        run "sudo passenger-install-apache2-module" do |ch,stream,out|  
          next if out.chomp == input.chomp || out.chomp == ''  
          print out  
          ch.send_data(input = $stdin.gets) if out =~ /enter/i  
        end
        cfg =<<-EOF
LoadModule passenger_module /usr/lib/ruby/gems/1.8/gems/passenger-2.0.3/ext/apache2/mod_passenger.so
PassengerRoot /usr/lib/ruby/gems/1.8/gems/passenger-2.0.3
PassengerRuby /usr/bin/ruby1.8
        EOF
        put cfg, "~/passenger"
        sudo "mv ~/passenger /etc/apache2/conf.d/passenger"
      end
  
      desc "Setup vhost"
      task :setup_vhost do
        cfg =<<-EOF
ServerName #{domain}
ServerAlias #{application}.agilebox.com
DocumentRoot #{deploy_to}/public
        EOF
        put cfg, "~/vhost"
        sudo "mv ~/vhost /etc/apache2/sites-available/#{application}"
        sudo "a2dissite default"
        sudo "a2ensite #{application}"
      end
  
      desc "Reload Apache"
      task :apache_reload do
        sudo "/etc/init.d/apache2 reload"
      end
  
      desc "Install Passenger"
      task :install do
        enable_passenger
        setup_vhost
        apache_reload
      end
  
    end
  end
end