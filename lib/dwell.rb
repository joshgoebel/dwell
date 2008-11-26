unless Capistrano::Configuration.respond_to?(:instance)
  abort "deprec2 requires Capistrano 2"
end

require "#{File.dirname(__FILE__)}/dwell/recipes"