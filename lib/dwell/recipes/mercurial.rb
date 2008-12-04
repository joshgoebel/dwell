Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :mercurial do

      desc "Install Mercurial (hg)"  
      task :install do  
        sudo "apt-get install mercurial -y"
        dwell1.record_install "mercurial"
      end

    end
  end
end