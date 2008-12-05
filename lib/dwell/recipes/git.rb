Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :git do

      desc "Install Git"  
      task :install do  
        sudo "apt-get install git-core curl gitweb git-svn -y"
        dwell1.record_install "git"
      end

      before "deploy" do
        return unless scm==:git
        st=`git status`
        if st=~/branch is ahead/ and not ENV['FORCE']
          puts
          puts " * Your local branch appears to be ahead of the remote.  Do you need to push?"
          puts " * You can force a deploy with FORCE=whatever if you wish."
          puts
          exit
        end
      end

    end
  end
end