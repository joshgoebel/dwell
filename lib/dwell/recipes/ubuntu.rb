Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :ubuntu do

      set :dwell_subversion, nil

      desc "Update apt-get sources"  
      task :update do  
        sudo "apt-get update"  
      end

      desc "Update distribution"  
      task :dist_upgrade do
        sudo "apt-get dist-upgrade -y"
      end

      desc "Enable build utilities"
      task :enable_build_tools do
        sudo "apt-get install build-essential -y"
        sudo "apt-get install wget -y" # needed later
      end
  
      desc "kill the default message of the day"
      task :kill_motd do
        sudo "test ! -f /etc/motd || mv /etc/motd /etc/motd.silent"
      end
  
      task :setup_dwell_storage do
        dwell1.mkdir "/etc/dwell", :mode => 0755, :owner => "root.admin", :via => :sudo
        dwell1.append_to_file_if_missing "/etc/dwell/version", "Dwell 0.1 #{dwell_subversion if dwell_subversion}"
        sudo "touch /etc/dwell/install_log"
      end
  
      desc "Prepare ubuntu server"
      task :prepare do
        setup_dwell_storage
        kill_motd
        update
        dist_upgrade
        enable_build_tools
      end

    end
  end
end