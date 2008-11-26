namespace :mysql do
  
  desc "Install MySQL5"
  task :install do
    sudo "apt-get install mysql-server mysql-client libmysqlclient15-dev -y"
  end
  
end