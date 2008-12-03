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

## the user to use when creating new databases and such
# set :mysql_admin, "root"

## hosts to automatically add to ssh known_hosts for your deploy user
## only github is currently supported
# set :known_hosts, [:github]

## other dwell packages to install on this server
# set :dwell_install, ["imagemagick"]

## a specific rails version your app depends on, will be
## gem installed during dwell:install
# set :rails_gem_version, "=2.1.2"

# set :apache_server_name, nil
# set :apache_default_vhost, false
# set :apache_ctl, "/etc/init.d/apache2"
# set :apache_server_aliases, []
# set :apache_ssl_enabled, false
# set :apache_ssl_ip, nil
# set :apache_ssl_forward_all, false
