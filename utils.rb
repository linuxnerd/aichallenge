module Utils
  # For ordering ant
  def spherical_distance(loc_a, loc_b, row_max, col_max)
    vertical_side = if (loc_a.row - loc_b.row).abs > row_max/2
                      row_max - (loc_a.row - loc_b.row).abs
                    else
                      (loc_a.row - loc_b.row).abs
                    end

    horizontal_side = if (loc_a.col - loc_b.col).abs > col_max/2
                      col_max - (loc_a.col - loc_b.col).abs
                    else
                      (loc_a.col - loc_b.col).abs
                    end

    Math.hypot(vertical_side, horizontal_side)
  end

  # For calculating vision
  def straight_distance(loc_a, loc_b)
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