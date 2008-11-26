namespace :dwell do
  namespace :ubuntu do

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
    end
  
    desc "Prepare ubuntu server"
    task :prepare do
      update
      dist_upgrade
      enable_build_tools
    end

  end
end