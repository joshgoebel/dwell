Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :ruby_enterprise do
      
      desc "Install Ruby Enterprise 1.8.6 for Ubuntu 8.04"
      task :install do
        run "wget -c http://rubyforge.org/frs/download.php/41041/ruby-enterprise_1.8.6-20080810-i386.deb"
        sudo "dpkg -i ruby-enterprise_1.8.6-20080810-i386.deb"
        dwell1.record_install "enterprise_ruby"
      end
    end
    
    namespace :ruby do
  
      desc "Install Ruby 1.8.6"
      task :install do
        sudo "apt-get install ruby rdoc ri irb libopenssl-ruby1.8 ruby1.8-dev -y"
        dwell1.record_install "ruby"
      end

    end
  end
end