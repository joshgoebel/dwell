Capistrano::Configuration.instance(:must_exist).load do 

  before  'deploy:update_code', 'dwell:rails:symlinks:setup'
  after   'deploy:symlink', 'dwell:rails:symlinks:update'
  after   :deploy,'deploy:cleanup'

  namespace :dwell do
    namespace :rails do
      
      desc "fully setup the application and cold deploy it"
      task :setup_and_deploy_cold do
        top.deploy.setup
        top.app.db.setup
        top.app.web.setup
        top.deploy.cold
      end
      
      desc "install the gems specified with config.gem"
      task :install_app_gems do
        run "grep '^[^#]*config.gem' #{current_path}/config/environment.rb && " +
          "cd #{current_path} && #{sudo} rake gems:install"
      end
      
      desc "copy deploy keys (public and private) to the server and setup known_hosts"
      task :setup_deploy_keys do
        if File.exist?("config/dwell/deploy_keys/#{user}")
          put File.read("config/dwell/deploy_keys/#{user}"), "/home/#{user}/.ssh/id_rsa", :mode => 0600
          sudo "chown #{user}.admin /home/#{user}/.ssh/id_rsa"
          put File.read("config/dwell/deploy_keys/#{user}.pub"), "/home/#{user}/.ssh/id_rsa.pub", :mode => 0600
          sudo "chown #{user}.admin /home/#{user}/.ssh/id_rsa.pub"
        end
        Dir.glob("config/dwell/known_hosts/*").each do |file|
          key=File.open(file).read
          dwell1.append_to_file_if_missing("/home/#{user}/.ssh/known_hosts", key)
        end
        sudo "chown #{user}.admin /home/#{user}/.ssh/known_hosts"
      end
      
      namespace :shared do
        desc "dump shared file to archive" 
        task :archive, :roles => :app, :only => { :primary => true } do
          to_backup=[]
          app_symlinks.map do |key, value|
            prefix=(key==:root) ? '' : key.to_s + "/"
            value.each { |d| to_backup << "shared/#{prefix}#{d}" unless d=="tmp" }
          end
          run "cd #{deploy_to} && tar -czf shared.tar.gz #{to_backup.join " "}"
        end

        desc "extract shared on the remote host"
        task :extract, :roles => :app, :only => { :primary => true } do
          if Capistrano::CLI.ui.agree("Confirm extract of shared.tar.gz on remote host? (y/n)")
            run "cd #{deploy_to} && tar -xzf shared.tar.gz"
          end
        end

        desc "fetch shared files locally"
        task :fetch, :roles => :app, :only => { :primary => true } do
          get "#{deploy_to}/shared.tar.gz", "shared.tar.gz"
        end

        desc "push shared archive to the remote"
        task :push, :roles => :app, :only => { :primary => true } do
          upload "shared.tar.gz", "#{deploy_to}/shared.tar.gz"
        end
        
      end
      
      namespace :symlinks do

        set :app_symlinks, {}

        def new_symlink_style
          set :app_symlinks, { :public => app_symlinks } if app_symlinks.is_a?(Array)
        end
  
        desc "Setup application symlinks in the public"
        task :setup, :roles => [:app, :web] do
          new_symlink_style
          app_symlinks.each do |key, value|
            dir=(key==:root) ? "" : key+"/"
            value.each { |link| run "mkdir -p #{shared_path}/#{dir}#{link}" }
          end
        end

        desc "Link public directories to shared location."
        task :update, :roles => [:app, :web] do
          new_symlink_style
          app_symlinks.each do |key, value|
            dir=(key==:root) ? "" : key+"/"
            value.each { |link| run "ln -nfs #{shared_path}/#{dir}#{link} #{current_path}/#{dir}#{link}" }
          end
        end

      end
    end
  end
end