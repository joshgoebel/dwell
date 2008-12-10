Capistrano::Configuration.instance(:must_exist).load do 

  namespace :dwell do
    namespace :campfirenow do
      set :campfire, nil
      # set :campfire, {
      #   :account => "campfireurl",
      #   :login => "user@email.com",
      #   :password => "blah",
      #   :ssl => true,
      #   :room => "Dwell Room"
      # }

      def campfire_bot
        @bot ||= begin
          svc=Tinder::Campfire.new(campfire[:account], {:ssl => campfire[:ssl]})
          svc.login(campfire[:login],campfire[:password])
          room=svc.find_room_by_name(campfire[:room])
          room
        end
      end
    
      def speak(message)
        return unless campfire
        require 'tinder' unless defined?(Tinder)
        campfire_bot.speak(message) 
      end
    
      after "deploy:restart" do
        speak "* #{application} has been restarted on #{domain.upcase}."
      end

      after "app:stop" do
        speak "* #{application} has been stopped on #{domain.upcase}."
      end

      after "app:start" do
        speak "* #{application} has been started on #{domain.upcase}."
      end

      after "deploy" do
        speak "* Revision ##{real_revision} has been deployed to #{domain.upcase}."
      end
  
      after "deploy:migrate" do
        speak "* Migrations have been run on #{domain.upcase}."
      end

      after "deploy:cleanup" do
        speak "* Cleaning old deploys from #{domain.upcase}."
      end

    end
  end
end