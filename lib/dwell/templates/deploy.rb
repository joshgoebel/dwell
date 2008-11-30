require 'dwell'

# Application Details
set :application, "myapp"
set :domain,      "myapp.com"
set :repository,  "svn://myapp.com/trunk"

# Server-wide Details 
set :user, "deploy"
set :deploy_to, "/var/www/#{application}"
server "myserver.com", :app, :web, :db, :primary => true
default_run_options[:pty] = true
