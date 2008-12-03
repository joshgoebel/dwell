unless Capistrano::Configuration.respond_to?(:instance)
  abort "dwell requires Capistrano 2"
end

# abort "Domain variable must be configured:\nset :domain, 'myapp.com'" unless defined?(domain)

require "#{File.dirname(__FILE__)}/dwell/recipes"
require "#{File.dirname(__FILE__)}/dwell/cap_extensions"
require "#{File.dirname(__FILE__)}/dwell/ubuntu_extensions"