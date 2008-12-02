Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :svn do
  
      desc "Install SVN"
      task :install do
        sudo "apt-get install subversion -y"
        dwell1.record_install "subversion"
      end
  
    end
  end
end