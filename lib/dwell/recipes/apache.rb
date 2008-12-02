Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :apache do

      desc "Install Apache"  
      task :install do
        sudo "apt-get install apache2 apache2-threaded-dev -y"
        dwell1.record_install "apache2"
      end
  
    end
  end
end