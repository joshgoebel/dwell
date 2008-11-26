require "#{File.dirname(__FILE__)}/recipes/ubuntu"
require "#{File.dirname(__FILE__)}/recipes/apache"
require "#{File.dirname(__FILE__)}/recipes/mysql"
require "#{File.dirname(__FILE__)}/recipes/svn"
require "#{File.dirname(__FILE__)}/recipes/git"
require "#{File.dirname(__FILE__)}/recipes/ruby"
require "#{File.dirname(__FILE__)}/recipes/gems"
require "#{File.dirname(__FILE__)}/recipes/passenger"

Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    
    desc "Install Rails Production Environment"
    task :install do
      top.dwell.ubuntu.prepare
      top.dwell.apache.install
      top.dwell.mysql.install
      top.dwell.svn.install
      top.dwell.git.install
      top.dwell.ruby.install
      top.dwell.gems.install
      top.dwell.passenger.install
    end
  
  end
end
