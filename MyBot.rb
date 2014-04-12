$:.unshift File.dirname($0)
require 'ants.rb'
require 'logger.rb'

class Foods
  attr_reader :locations

  def initialize
    @locations = []
  end

  # find all foods to the array named locations
  def in map
    @locations = []

    map.each do |row|
      row.each do |square|

        if square.food? && !@locations.include?(square)
          @locations << square
        end

      end # row loop
    end # map loop
  end

end

#################################
#declarations
#################################
ai            = AI.new
@logger        = Logger.new
foods         = Foods.new
explored_map  = [] # nothing yet
# end of declarations


ai.setup do |ai|
  # your setup code here, if any
end

def distance from, to
  distance = (from.row - to.row).abs + (from.col - to.col).abs
  { :distance => distance, :from => from, :to => to }
end

def order ant, direction
  new_location = ant.square.neighbor(direction)
  if !@orders.include?(new_location) 
        && new_location.land?
        && !new_location.ant?
    ant.order direction
    @orders[new_location] = ant.square
    return true
  end
  return false
end

def move ant, to
  one_turn_direction = []

  case
  when ant.square.row - to.row > 0
    one_turn_direction << 'N'
  when ant.square.row - to.row < 0
    one_turn_direction << 'S'
  end

  case 
  when ant.square.col - to.col > 0
    one_turn_direction << 'W'
  when ant.square.col - to.col < 0
    one_turn_direction << 'E'
  end
  
  rand_direction = one_turn_direction[rand(one_turn_direction.length) - 1]

  if order(ant, rand_direction)
    return true
  else
    return false
  end
end


ai.run do |ai|
  # your turn code here
  @orders = {}
  ant_dist = []

  foods.in(ai.map)
  ai.my_ants.each do |ant|

    foods.locations.each do |food|
      ant_dist << distance(ant, food)
    end
    ant_dist.sort_by! { |hash| hash[:distance]}

    ant_dist.each do |food_target|
      break if move(ant, food_target[:to])
    end

  end
end