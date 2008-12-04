require 'capistrano'
require 'fileutils'

module Dwell1

  def record_install(package)
    dwell1.append_to_file_if_missing "/etc/dwell/install_log", package
  end

  def config_gsub(file, find, replace)
    tmp="/tmp/#{File.basename(file)}"
    get file, tmp
    content=File.open(tmp).read
    content.gsub!(find,replace)
    put content, tmp
    sudo "mv #{tmp} #{file}"
  end

  def append_to_file_if_missing(filename, value, options={})
    # XXX sort out single quotes in 'value' - they'l break command!
    # XXX if options[:requires_sudo] and :use_sudo then use sudo
    sudo <<-END
    sh -c '
    grep -F "#{value}" #{filename} > /dev/null 2>&1 || 
    echo "#{value}" >> #{filename}
    '
    END
  end
  
  def sudo_upload(from, to, options={}, &block)
    top.upload from, "/tmp/#{File.basename(to)}", options, &block
    sudo "mv /tmp/#{File.basename(to)} #{to}"
    sudo "chmod #{options[:mode]} #{to}" if options[:mode]
    sudo "chown #{options[:owner]} #{to}" if options[:owner]
  end
  
  def adduser(user, options={})
    options[:shell] ||= '/bin/bash' # new accounts on ubuntu 6.06.1 have been getting /bin/sh
    switches = '--disabled-password --gecos ""'
    switches += " --shell=#{options[:shell]} " if options[:shell]
    switches += ' --no-create-home ' if options[:nohome]
    switches += " --ingroup #{options[:group]} " unless options[:group].nil?
    invoke_command "grep '^#{user}:' /etc/passwd || sudo /usr/sbin/adduser #{user} #{switches}", 
    :via => run_method
  end
  
  # create directory if it doesn't already exist
  # set permissions and ownership
  # XXX move mode, path and
  def mkdir(path, options={})
    via = options.delete(:via) || :run
    # XXX need to make sudo commands wrap the whole command (sh -c ?)
    # XXX removed the extra 'sudo' from after the '||' - need something else
    invoke_command "test -d #{path} || #{sudo if via == :sudo} mkdir -p #{path}"
    invoke_command "chmod #{sprintf("%3o",options[:mode]||0755)} #{path}", :via => via if options[:mode]
    invoke_command "chown -R #{options[:owner]} #{path}", :via => via if options[:owner]
#    groupadd(options[:group], :via => via) if options[:group]
    invoke_command "chgrp -R #{options[:group]} #{path}", :via => via if options[:group]
  end
  
  ##
  # Run a command and ask for input when input_query is seen.
  # Sends the response back to the server.
  #
  # +input_query+ is a regular expression that defaults to /^Password/.
  #
  # Can be used where +run+ would otherwise be used.
  #
  #  run_with_input 'ssh-keygen ...', /^Are you sure you want to overwrite\?/

  def run_with_input(shell_command, input_query=/^Password/, response=nil)
    handle_command_with_input(:run, shell_command, input_query, response)
  end

  ##
  # Run a command using sudo and ask for input when a regular expression is seen.
  # Sends the response back to the server.
  #
  # See also +run_with_input+
  #
  # +input_query+ is a regular expression

  def sudo_with_input(shell_command, input_query=/^Password/, response=nil)
    handle_command_with_input(:sudo, shell_command, input_query, response)
  end

  def invoke_with_input(shell_command, input_query=/^Password/, response=nil)
    handle_command_with_input(run_method, shell_command, input_query, response)
  end
  
  private
  
  ##
  # Does the actual capturing of the input and streaming of the output.
  #
  # local_run_method: run or sudo
  # shell_command: The command to run
  # input_query: A regular expression matching a request for input: /^Please enter your password/

  def handle_command_with_input(local_run_method, shell_command, input_query, response=nil)
    send(local_run_method, shell_command, {:pty => true}) do |channel, stream, data|
      logger.info data, channel[:host]
      if data =~ input_query
        if response
          channel.send_data "#{response}\n"
        else 
          response = ::Capistrano::CLI.password_prompt "#{data}"
          channel.send_data "#{response}\n"
        end
      end
    end
  end
  
  
end

Capistrano.plugin :dwell1, Dwell1

