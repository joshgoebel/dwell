namespace :dwell do
  namespace :git do

    desc "Install Git"  
    task :install do  
      sudo "apt-get install git-core curl gitweb git-svn -y"  
    end

  end
end