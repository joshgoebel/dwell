require 'rubygems' 

SPEC = Gem::Specification.new do |s|
  s.name = 'dwell'
  s.version = '0.1'
  
  s.authors = ['Robert Bousquet','Josh Goebel']
  s.description = "Automated Rails production environment setup for Ubuntu"
  s.email = 'robert@robertbousquet.com'
  s.homepage = 'http://github.com/bousquet/dwell'
  s.summary = 'Automated Rails production environment setup for Ubuntu'

  s.require_paths = ['lib']
  s.add_dependency('capistrano', '> 2.0.0')
  candidates = Dir.glob("{bin,lib}/**/*") 
  candidates.concat(%w(LICENSE README.txt))
  s.files = candidates.delete_if do |item| 
    item.include?("CVS") || item.include?("rdoc") 
  end
  s.default_executable = "dwell"
  s.executables = ["dwell"]
end
