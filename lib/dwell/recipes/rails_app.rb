Capistrano::Configuration.instance(:must_exist).load do 
  namespace :app do
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
  
  namespace :deploy do
    
    set :known_hosts, []
    
    def railsmachine_gem?
      top.respond_to?(:apache) and top.apache.respond_to?(:set_apache_conf)
    end

    after "deploy:setup" do
      fix_permissions
      setup_deploy_keys
    end

    task :fix_permissions do
      sudo "chown -R #{user}:admin #{deploy_to}"
    end

    task :setup_deploy_keys do
      if File.exist?("config/dwell/deploy_keys/#{user}")
        put File.read("config/dwell/deploy_keys/#{user}"), "/home/#{user}/.ssh/id_rsa", :mode => 0600
        sudo "chown #{user}.admin /home/#{user}/.ssh/id_rsa"
        put File.read("config/dwell/deploy_keys/#{user}.pub"), "/home/#{user}/.ssh/id_rsa.pub", :mode => 0600
        sudo "chown #{user}.admin /home/#{user}/.ssh/id_rsa.pub"
      end
      known_hosts.each do |host|
        key=File.open("#{File.dirname(__FILE__)}/../known_hosts/#{host}").read
        dwell1.append_to_file_if_missing("/home/#{user}/.ssh/known_hosts", key)
      end
      sudo "chown #{user}.admin /home/#{user}/.ssh/known_hosts"
    end
    
    task :install_app_gems do
      run "grep '^[^#]*config.gem' #{current_path}/config/environment.rb && " +
        "cd #{current_path} && #{sudo} rake gems:install"
    end

    before  'deploy:update_code', 'app:symlinks:setup'
    after   'deploy:symlink', 'app:symlinks:update'
    after   :deploy,'deploy:cleanup'
    
    # don't mess with rails machine stuff
    unless railsmachine_gem?
        
      puts "restart your rails app"
      task :restart do
        run "touch #{current_path}/tmp/restart.txt"
      end

      [:start, :stop].each do |t|
        desc "The :#{t} task has no effect when using Passenger as your application server."
        task t, :roles => :app do
          puts "The :#{t} task has no effect when using Passenger as your application server."
        end
      end
    
      # pulled from Capistrano and enhanced with gem installs
      desc "cold app deploy that does gem installs as well"
      task :cold do
        update
        install_app_gems
        migrate
        top.dwell.apache.reload
      end
    
    end
    
    namespace :db do
      
      desc "setup the database automatically"
      task :setup do
        top.dwell.mysql.db.create
      end
      
    end
    
    namespace :web do
      
      desc "setup a passenger config for this app"
      task :setup do
        top.dwell.apache.setup_vhost
        copy_certs
      end
      
      task :copy_certs do
        Dir.glob("config/dwell/ssl/*").each do |file|
          basename=File.basename(file)
          dwell1.sudo_upload file, "/etc/ssl/certs/#{basename}" if file=~/.crt/
          if file=~/.key/      
            dwell1.sudo_upload file, "/etc/ssl/private/#{basename}", :mode => 0600, :owner => "root.admin"
          end
        end
      end

    end
  end
end
