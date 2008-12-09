DWELL - Capistrano recipe to setup a production Rails environment on Ubuntu.
============================================================================


Install Capistrano2 (if you don't already have it) then build and install this gem:

    sudo gem install capistrano
    gem build dwell.gemspec
    sudo gem install dwell-0.2.gem
    

Usage
-----

1. From within your Rails directory, run: 
    `capify .`
2. Click this link for recommended contents of config/deploy.rb: `http://pastie.org/private/lodo1zveqgc2i0rto9idw`
3. Configure you application name, domain, repository location and server name details in your deploy.rb
4.  Bootstrap your server (see docs below) with `cap dwell:server:bootstrap` or `cap dwell:linode:bootstrap` 
5. Install the Dwell stack and any optional packages: `cap dwell:install`
6. Setup your rails app and Apache vhost, etc: `cap dwell:rails:setup_and_deploy_cold`


The Dwell Stack - dwell:install
-----------------------------

1. Updates Ubuntu sources and distro
2. Installs Apache2
3. Installs MySQL5
4. Installs Subversion and Git
5. Installs Ruby, RubyGems, Rails and Merb
6. Installs Passenger module for Apache2
7. Installs any optional packages listed in `:dwell_install`


### Optional Packages

You can specify optional packages to be installed during `dwell:install` in your deploy.rb file:

    set :dwell_optional_installs, [:postfix, :imagemagick, :php]
    
Optional packages include:

- postfix
- mercurial
- tinydns
- php (sets up php via fastcig)
- imagemagick (binary, gem, and mini-magick gem)
- sqlite (binary and gem)


Bootstrapping
-------------

###  dwell:server:bootstrap

1. Creates a user account for :user (default 'deploy') in the admin group
2. Gives the admin group sudo rights if they haven't already
3.  Copies authorized SSH keys to the remote host
    
    Authorized keys should be in the file `config/dwell/authorized_keys/:user`
    
4.  Copies deploy keys (if found) to the remote host (needed for git, etc)

    Deploy keys (public and private) should be in the files:
    `config/dwell/deploy_keys/:user.pub` and `config/dwell/deploy_keys/:user`

5. Disables SSH logins for the root account


###  dwell:linode:bootstrap

1. Calls out to server:bootstrap show above
2. Uses the DHCP IP assignment to configure a static IP and disable DHCP
3.  Sets up the hostname of the box from what was passed in HOSTS

    You MUST pass the host (singular) in HOSTS to bootstrap Linode as the bootstrap needs to know the hostname to properly configure the box.

    `HOSTS="my.new.box.com" cap dwell:linode:bootstrap`


Apache Notes - dwell:apache
---------------------------

SSL certificates will be copied and installed if available.  This will happen automatically during a `setup_and_deploy_cold` or you can do it manually with `cap dwell:apache:copy_certs`.

SSL certificates should be located locally in:
`config/dwell/ssl/*.crt` and `config/dwell/ssl/*.key`

When your apache virtual host is setup (`cap dwell:apache:site:setup`, also part of `setup_and_deploy_cold`) these same keys will referenced automatically in your apache configs if you have set `:apache_ssl_enabled`.

Any key with `CA` in it's name is assumged to be a Certificate Authority and added to your Apache config as such (`SSLCACertificateFile`).