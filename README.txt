DWELL  --  Capistrano recipe to setup a production Rails environment on Ubuntu.


1) Install Capistrano2 if you don't already have it:
$ sudo gem install capistrano

2) Build this gem:
$ gem build dwell.gemspec

3) Install gem with:
$ sudo gem install dwell-0.1.gem



USAGE

1) From within your Rails directory, run:
$ capify .

2) Paste the following into the config/deploy.rb

set :application, "myapp"
set :domain, "myapp.com"
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify your SCM below:
# set :scm, :subversion
set :repository,  "set your repository location here"

server :app, :web, :db, "myapp.com", :primary => true


3) Configure, application name, domain, repository location and server name

4) Then run cap dwell:install



STACK DETAILS

1) Updates Ubuntu sources and distro
2) Installs Apache2
3) Installs MySQL5
4) Installs Subversion and Git
5) Installs Ruby, RubyGems, Rails and Merb
6) Installs Passenger module for Apache2 and creates basic config

TODO

* Generate production mysql db with details from database.yml
* Create enhanced VirtualHost configs for Apache that include SSL
* Configure merb uploader with controls