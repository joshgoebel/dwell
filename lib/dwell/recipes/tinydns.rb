Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :tinydns do

      task :add_intrepid_sources, :roles => :dns do
        dwell1.append_to_file_if_missing "/etc/apt/sources.list", 
          "deb-src http://archive.ubuntu.com/ubuntu intrepid main restricted universe multiverse"
        sudo "apt-get update"  
      end

      task :build_from_source, :roles => :dns do
        add_intrepid_sources
        run "#{sudo} rm -rf tmp"
        run "mkdir tmp"
        run "cd tmp && #{sudo} apt-get -b source -t intrepid djbdns"
        run "cd tmp && #{sudo} dpkg -i *.deb"
        run "#{sudo} rm -rf tmp"
      end
      
      desc "Install daemontools"  
      task :install, :roles => :dns do
        if ubuntu1.lsb_info[:distrib_codename]=="intrepid"
          sudo "apt-get install djbdns -y"
        else
          puts "You are running #{ubuntu1.lsb_info[:distrib_codename]}. Building .debs from source."
          sleep 2
          build_from_source
        end
        dwell1.record_install "tinydns"
      end
      
      set :dns_ip, nil
      
      task :setup, :roles => :dns do
        if dns_ip.nil?
          puts "Please set dns_ip in your deploy file to the IP of your DNS server."
          exit
        end
        dwell1.adduser "tinydns", :nohome => true
        sudo "tinydns-conf tinydns tinydns /etc/tinydns #{dns_ip}"
        sudo "ln -s /etc/tinydns /etc/service"
        sleep 2
        run "svstat /etc/service/tinydns"
      end
      
      # control
      
      desc "Start tinydns"
      task :start, :roles => :dns do
        sudo "svc -u /etc/service/tinydns"
      end
      
      desc "Stop tinydns"
      task :stop, :roles => :dns do
        sudo "svc -d /etc/service/tinydns"
      end
  
    end
  end
end