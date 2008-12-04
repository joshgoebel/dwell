Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :sqlite do
  
      desc "Install Sqlite3"
      task :install do
        sudo "apt-get install sqlite3 libsqlite3-dev -y"
        sudo "gem install sqlite3-ruby --no-rdoc --no-ri"
        dwell1.record_install "sqlite3"
      end

    end
  end
end