namespace :dwell do
  namespace :gems do
  
    desc "Install RubyGems"
    task :install_rubygems do
      ["cd /usr/local/src/",
       "sudo wget http://rubyforge.org/frs/download.php/45905/rubygems-1.3.1.tgz",
       "sudo tar xzf rubygems-1.3.1.tgz",
       "cd rubygems-1.3.1",
       "sudo ruby setup.rb",
       "sudo ln -s /usr/bin/gem1.8 /usr/bin/gem"].each {|cmd| run cmd}
    end
  
    desc "Install Gems"
    task :install_gems do
      sudo "gem install rails capistrano rspec passenger mysql rdoc merb --no-rdoc --no-ri"
    end
  
    desc "Installation"
    task :install do
      install_rubygems
      install_gems
    end

  end
end