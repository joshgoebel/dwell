Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :mysql do
  
      desc "Install MySQL5"
      task :install do
        sudo "apt-get install mysql-server mysql-client libmysqlclient15-dev -y"
      end

    end
  end
end