module Utils
  def distance(loc_a, loc_b)
    Math.hypot(loc_a.col - loc_b.col, loc_a.row - loc_b.row)
  end

  class Logger
    attr_accessor :logfile

    def initialize(file)
      @logfile = file
    end

    def info message
      message ||= "nil"
      file_stream = File.new(@logfile, "a")
      file_stream.write("[" + Time.now.strftime("%Y-%m-%d %H:%M:%S") + "]" + message.to_s + "\n")
      file_stream.close  
    end
  end

end