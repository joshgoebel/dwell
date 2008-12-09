DWELL - Capistrano recipe to setup a production Rails environment on Ubuntu.
============================================================================


1) Install Capistrano2 if you don't already have it:
$ sudo gem install capistrano

2) Build this gem:
$ gem build dwell.gemspec

3) Install gem with:
$ sudo gem install dwell-0.2.gem



Usage
-----

1) From within your Rails directory, run:
$ capify .

2) Click this link for recommended contents of config/deploy.rb:
http://pastie.org/private/lodo1zveqgc2i0rto9idw

3) Configure application name, domain, repository location and server name details

4) Bootstrap your server (which copies over ssh keys, sets up the deploy account, etc)
   There is also a dwell:linode:bootstrap if you're using Linode.
$ cap dwell:server:bootstrap

4) Install the full Dwell stack and any optional packages you (specified with :dwell_install)
$ cap dwell:install

4) Setup your rails app and Apache vhost, etc
$ cap dwell:rails:setup_and_deploy_cold


Stack Details
-------------

1) Updates Ubuntu sources and distro
2) Installs Apache2
3) Installs MySQL5
4) Installs Subversion and Git
5) Installs Ruby, RubyGems, Rails and Merb
6) Installs Passenger module for Apache2 and creates basic config
