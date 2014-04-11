class Logger
  def log message
    message ||= "nil"
    logfile = File.new("game_logs/ants.log", "a")
    logfile.write("[" + Time.now.strftime("%Y-%m-%d %H:%M:%S") + "]" + message.to_s + "\n")
    logfile.close  
  end
end