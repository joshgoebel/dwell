Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :svn do
  
      desc "Install SVN"
      task :install do
        sudo "apt-get install subversion -y"
      end
  
    end
  end
end