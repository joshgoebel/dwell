Dir.glob("#{File.dirname(__FILE__)}/recipes/*").each { |f| require f if File.file?(f) }
Dir.glob("#{File.dirname(__FILE__)}/recipes/bootstrap/*").each { |f| require f }
Dir.glob("#{File.dirname(__FILE__)}/recipes/extras/*").each { |f| require f }

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
