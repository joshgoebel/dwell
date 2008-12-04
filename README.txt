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

2) Click this link for recommended contents of config/deploy.rb:
http://pastie.org/private/lodo1zveqgc2i0rto9idw

3) Configure application name, domain, repository location and server name details

4) $ cap dwell:install



STACK DETAILS

1) Updates Ubuntu sources and distro
2) Installs Apache2
3) Installs MySQL5
4) Installs Subversion and Git
5) Installs Ruby, RubyGems, Rails and Merb
6) Installs Passenger module for Apache2 and creates basic config

