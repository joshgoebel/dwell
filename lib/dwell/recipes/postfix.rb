Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :postfix do
  
      desc "Install Postfix"
      task :install do
        sudo "DEBCONF_TERSE='yes' DEBIAN_FRONTEND=noninteractive apt-get install postfix -y"
        dwell1.record_install "postfix"
      end

    end
  end
end