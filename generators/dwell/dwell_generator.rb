require 'rbconfig'

class DwellGenerator < RubiGen::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  default_options   :shebang => DEFAULT_SHEBANG,
                    :an_option => 'some_default'

  attr_reader :app_name, :module_name

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    init = args.shift
    if init!="init"
      puts "ERROR: #{init} is not a supported command\n\n"
      usage
      exit(0)
    end
    @destination_root = args.shift || "."
  end

  def manifest
    # Use /usr/bin/env if no special shebang was specified
    script_options     = { :chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : 
    options[:shebang] }
    windows            = (RUBY_PLATFORM =~ /dos|win32|cygwin/i) || (RUBY_PLATFORM =~ /(:?mswin|mingw)/)

    record do |m|
      # Root directory and all subdirectories.
#      m.directory ''
      BASEDIRS.each { |path| m.directory path }
  
      # Root
#      m.template_copy_each %w( Rakefile )
#      m.file_copy_each     %w( config/deploy.rb )
      m.template "deploy.rb", "config/deploy.rb"
      m.file "known_hosts/github", "config/dwell/known_hosts/github"

      # Test helper
#      m.template   "test_helper.rb",        "test/test_helper.rb"

      # Scripts
      # %w( generate ).each do |file|
      #   m.template "script/#{file}",        "script/#{file}", script_options
      #   m.template "script/win_script.cmd", "script/#{file}.cmd", 
      #     :assigns => { :filename => file } if windows
      end
   
    end

  protected
    def banner
      <<-EOS
Creates a default deploy.rb and sets up the config/dwell directory tree.

Usage: #{File.basename $0} init [/path/to/rails/app] [options]
EOS
    end

    def add_options!(opts)
      opts.separator ''
      opts.separator "#{File.basename $0} options:"
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

  # Installation skeleton.  Intermediate directories are automatically
  # created so don't sweat their absence here.
  BASEDIRS = %w(
    config
    config/dwell
    config/dwell/authorized_keys
    config/dwell/authorized_keys/deploy
    config/dwell/deploy_keys
    config/dwell/known_hosts
    config/dwell/ssl
    config/dwell/ssl/ca
  )
end
