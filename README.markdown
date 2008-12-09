DWELL - a cap recipe to setup a full Rails stack on Ubuntu
============================================================================


Install Capistrano2 (if you don't already have it) then build and install this gem:

    $ sudo gem install capistrano
    $ gem build dwell.gemspec
    $ sudo gem install dwell-0.2.gem
    

### Typical Usage

1. Capify your Rails directory
2. Initialize dwell inside your Rails directory (you'll want to overwrite deploy.rb)
3. Edit your deploy.rb: configure you applications name, domain, repository, server details, etc
4. Bootstrap your server
5. Install the Dwell stack and any optional packages
6. Setup your rails app and apache vhost then deploy cold

Or all said and done:
    
    $ capify .
    $ dwell init .
    $ cap dwell:server:bootstrap
    $ cap dwell:install
    $ cap dwell:rails:setup_and_deploy_cold    


The Dwell Stack - dwell:install
-----------------------------

1. Updates Ubuntu sources and distro
2. Installs Apache2
3. Installs MySQL5
4. Installs Subversion and Git
5. Installs Ruby, RubyGems, Rails and Merb
6. Installs Passenger module for Apache2
7. Installs any specified optional packages


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

1. Creates a user account for `:user` (default 'deploy') in the admin group
2. Gives the admin group sudo rights if they haven't already
3. Copies authorized SSH keys to the remote host (such as your own public key)
5. Disables SSH logins for the root account since we'll be using deploy and sudo

Authorized keys should be placed in sub-directories of the `authorized_keys` directory. For example, if your deployment user is named "deploy" then your setup might look something like this:

    config/dwell/authorized_keys/deploy/my_public_key.txt
    config/dwell/authorized_keys/deploy/another_devs_public_key.txt
    
You can update keys anytime (add or remove) and push them to your servers.  Pushing will overwrite ALL the remote keys with your new local keys.

    $ cap dwell:server:push_ssh_keys


###  dwell:linode:bootstrap

1. Does a `dwell:server:bootstrap` as show above
2. Uses the DHCP IP assignment to configure a static IP and disable DHCP
3. Sets up the hostname of the box from what was passed in HOSTS

You MUST pass the host (singular) in HOSTS to bootstrap a Linode as the bootstrap needs to know the hostname to properly configure the box.

    HOSTS="my.new.box.com" cap dwell:linode:bootstrap


Rails Notes - dwell:rails
--------------------------

### dwell:rails:setup\_and\_deploy\_cold

1. Does a traditional `cap:setup`
2. Copies deploy keys (if found) to the remote host (needed for git, etc)
3. Creates a mysql database with the authentication info in your database.yml
4. Sets up an apache vhost and SSL keys (if you're using SSL)
5. Deploys your code
6. Installs any necessary app gems with `rake gems:install`
7. Runs migrations
8. Reloads Apache which should fire up your app

Optional deploy keys (public and private) should be placed in `deploy_keys`:

    config/dwell/deploy_keys/:user.pub
    config/dwell/deploy_keys/:user


Apache Notes - dwell:apache
---------------------------

SSL certificates (if found) will be copied and installed during `setup_and_deploy_cold`.  You can also do this manually with `cap dwell:apache:copy_certs`.  These same certs will referenced automatically in your apache configs if you have set `:apache_ssl_enabled` in your deploy.rb.

SSL certificates should be place in `ssl`:

    config/dwell/ssl/ca/*.crt
    config/dwell/ssl/*.crt
    config/dwell/ssl/*.key

Any keys inside `ssl/ca` are assumed to be a Certificate Authority and are added to your Apache config using `SSLCACertificateFile`.