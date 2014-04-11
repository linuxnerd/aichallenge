$:.unshift File.dirname($0)
require 'ants.rb'
require 'logger.rb'

####################
#declarations
####################
ai              = AI.new
logger          = Logger.new
# end of declarations

ai.setup do |ai|
  # your setup code here, if any
end
 

def order ant, direction
  new_location = ant.square.neighbor(direction)
  if !@orders.include?(new_location) && new_location.land?
    ant.order direction
    @orders[new_location] = ant.square
    return true
  end
  return false
end

i=0
ai.run do |ai|
  # your turn code here
  @orders = {}
  @foods = []

  ai.my_ants.each do |ant|

    @map = ai.map
    @map.each do |row|
      row.each do |square|

        if square.food? && !@foods.include?(square)
          @foods << square
        end

      end
    end

    # try to go north, if possible; otherwise try east, south, west.
    [:N, :E, :S, :W].each do |direction|
      break if order(ant, direction)
    end
  end
end