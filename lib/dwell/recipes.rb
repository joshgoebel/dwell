require "#{File.dirname(__FILE__)}/recipes/ubuntu"
require "#{File.dirname(__FILE__)}/recipes/apache"
require "#{File.dirname(__FILE__)}/recipes/mysql"
require "#{File.dirname(__FILE__)}/recipes/svn"
require "#{File.dirname(__FILE__)}/recipes/git"
require "#{File.dirname(__FILE__)}/recipes/ruby"
require "#{File.dirname(__FILE__)}/recipes/gems"
require "#{File.dirname(__FILE__)}/recipes/passenger"

require "#{File.dirname(__FILE__)}/recipes/linode"
require "#{File.dirname(__FILE__)}/recipes/imagemagick"
require "#{File.dirname(__FILE__)}/recipes/daemontools"
require "#{File.dirname(__FILE__)}/recipes/tinydns"
require "#{File.dirname(__FILE__)}/recipes/rails_app"

Capistrano::Configuration.instance(:must_exist).load do 
  
  default_run_options[:pty] = true
  set :keep_releases, 3
  
  set :which_ruby, :system
  
  namespace :dwell do
    
    set :dwell_install, []
    
    desc "Install Rails Production Environment"
    task :install do
      top.dwell.ubuntu.prepare
      top.dwell.apache.install
      top.dwell.mysql.install
      top.dwell.svn.install
      top.dwell.git.install
      top.dwell.ruby.install
      top.dwell.ruby_enterprise.install if which_ruby==:enterprise
      top.dwell.gems.install
      top.dwell.passenger.install
      dwell_install.each do |package_name|
        top.dwell.send(package_name).install
      end
    end
  
  end
end
