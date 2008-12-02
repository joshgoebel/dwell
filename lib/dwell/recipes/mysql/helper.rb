module MySQLMethods
  
  def execute(sql, user)
    run "mysql --user=#{user} -p --execute=\"#{sql}\"" do |channel, stream, data|
      handle_mysql_password(user, channel, stream, data)
    end
  end
  
  private
  def handle_mysql_password(user, channel, stream, data)
    logger.info data, "[database on #{channel[:host]} asked for password]"
    if data =~ /^Enter password:/
      pass = Capistrano::CLI.password_prompt "Enter database password for '#{user}':"
      channel.send_data "#{pass}\n" 
    end
  end
end

Capistrano.plugin :mysql_helper, MySQLMethods
