#!/usr/bin/env ruby
require 'rubygems' 

SPEC = Gem::Specification.new do |s|
  s.name = 'dwell'
  s.version = '0.1.99'
  
  s.authors = ['Robert Bousquet','Josh Goebel']
  s.description = "Automated Rails production environment setup for Ubuntu"
  s.email = 'robert@robertbousquet.com'
  s.homepage = 'http://github.com/bousquet/dwell'
  s.summary = 'Automated Rails production environment setup for Ubuntu'

  s.require_paths = ['lib']
  s.add_dependency('capistrano', '> 2.0.0')
#  candidates = Dir.glob("{bin,lib}/**/*") 
  candidates = ["bin/dwell", "lib/dwell", "lib/dwell/cap_extensions.rb", "lib/dwell/known_hosts", "lib/dwell/known_hosts/github", "lib/dwell/recipes", "lib/dwell/recipes/apache.rb", "lib/dwell/recipes/campfire.rb", "lib/dwell/recipes/daemontools.rb", "lib/dwell/recipes/gems.rb", "lib/dwell/recipes/git.rb", "lib/dwell/recipes/imagemagick.rb", "lib/dwell/recipes/linode.rb", "lib/dwell/recipes/mercurial.rb", "lib/dwell/recipes/mysql", "lib/dwell/recipes/mysql/base.rb", "lib/dwell/recipes/mysql/db.rb", "lib/dwell/recipes/mysql/helper.rb", "lib/dwell/recipes/mysql.rb", "lib/dwell/recipes/passenger.rb", "lib/dwell/recipes/php.rb", "lib/dwell/recipes/rails_app.rb", "lib/dwell/recipes/ruby.rb", "lib/dwell/recipes/sqlite.rb", "lib/dwell/recipes/svn.rb", "lib/dwell/recipes/tinydns.rb", "lib/dwell/recipes/ubuntu.rb", "lib/dwell/recipes.rb", "lib/dwell/templates", "lib/dwell/templates/deploy.rb", "lib/dwell/templates/passenger.conf", "lib/dwell/templates/vhost.conf", "lib/dwell/templates/vhost_ssl.conf", "lib/dwell/ubuntu_extensions.rb", "lib/dwell.rb"]
  candidates.concat(%w(LICENSE README.txt))
  s.files = candidates.delete_if do |item| 
    item.include?("CVS") || item.include?("rdoc") 
  end
  s.default_executable = "dwell"
  s.executables = ["dwell"]
end

if __FILE__ == $0
  puts "Rewriting candidates..."
  files=Dir.glob("{bin,lib}/**/*")
  spec=File.read("dwell.gemspec")
  spec.gsub!(/^(  candidates = )\[.*$/, "\\1" + files.inspect)
  File.open("dwell.gemspec","w").write(spec)
end
