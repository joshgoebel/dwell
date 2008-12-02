Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :git do

      desc "Install Git"  
      task :install do  
        sudo "apt-get install git-core curl gitweb git-svn -y"
        dwell1.record_install "git"
      end

    end
  end
end