namespace :dwell do
  namespace :apache do

    desc "Install Apache"  
    task :install do
      sudo "apt-get install apache2 apache2-threaded-dev -y"  
    end
  
  end
end