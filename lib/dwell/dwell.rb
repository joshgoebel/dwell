require "#{File.dirname(__FILE__)}/recipes"

namespace :dwell do
  
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