Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :ruby do
  
      desc "Install Ruby 1.8.6"
      task :install do
        sudo "apt-get install ruby rdoc ri irb libopenssl-ruby1.8 ruby1.8-dev -y"
      end

    end
  end
end