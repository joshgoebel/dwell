require 'rake'
require 'rubygems'

task :default => [:update_gemspec]

task :update_gemspec do
  puts "Rewriting candidates in gemspec..."
  files=Dir.glob("{bin,lib,generators}/**/*")
  spec=File.read("dwell.gemspec")
  spec.gsub!(/^(  candidates = )\[.*$/, "\\1" + files.inspect)
  File.open("dwell.gemspec","w").write(spec)
end

task :gem_install do
  puts `gem build dwell.gemspec`
  puts `sudo gem install dwell-0.2.1.gem`
end