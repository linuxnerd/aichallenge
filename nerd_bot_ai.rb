require 'utils.rb'

LOG_FILE = 'game_logs/ants.log'

####################################
class NerdBotAi
  include Utils

  def initialize
    @logger = Logger.new(LOG_FILE)
  end

  def setup(ai)
    @ai = ai
    @unseen = @ai.map.flatten
    @enemy_hills = [] 
  end

  def next_step
    move_ants_to next_directions
  end

  private
    
    def move_ants_to(directions)
      directions.each do |ant, dir|
        ant.order dir
      end
    end

    def next_directions
      # orders is hash like {:ant => :W}
      {}.tap do |orders|
        # gathering food
        t_food = FarmerTactics.new(@ai)
        t_food.update_orders(orders)
        
        # not blocking hill
        aimed_foods = t_food.aimed_foods
        s_blocking = NotBlockingHillTactics.new(@ai, '', aimed_foods)
        s_blocking.update_orders(orders)

        # update unseen map
        update_unseen

        # explorer unseen
        s_explorer = ExplorerTactics.new(@ai, @unseen)
        s_explorer.update_orders(orders)

      end
    end

    def update_enemy_hills
    end

    def update_unseen
      @unseen.delete_if do |square|
        @ai.my_ants.any? { |ant| ant.see?(square) }
      end
    end
end


####################################
class TacticsBase
  include Utils

  def initialize(ai, unseen='', aimed_foods='')
    @ai = ai
    @unseen = unseen
    @aimed_foods = aimed_foods
    @logger = Logger.new(LOG_FILE)
  end

  # Return directions like [:N,:E]
  def directions_for(from, to)
    [].tap do |result|
      result << :N if from.row > to.row
      result << :S if from.row < to.row
      result << :W if from.col > to.col
      result << :E if from.col < to.col
    end
  end

  # Return distances like [{:distance=>5.0, :target=>food, :ant=>ant}]
  def distances_for(ants, targets)
    [].tap do |distances|
      ants.each do |ant|
        distances.concat targets.map { |target| {:distance=>distance(ant, target), :target=>target, :ant=>ant} }
      end
    end
  end

  # Return { :food => ant }, only NotBlockingHillTactics needs
  def do_locate(distances, orders)
    aimed_targets = {}
    sorted_distances = distances.sort_by { |hash| hash[:distance] }

    sorted_distances.each do |move|
      ant = move[:ant]
      target = move[:target]
      if !aimed_targets.keys.include?(target) && !aimed_targets.values.include?(ant)

        # random direction
        directions_for(ant, target).shuffle.each do |dir|
          if try_to_occupied(ant, dir, orders)
            aimed_targets[target] = ant
            break
          end
        end
      end
    end
    aimed_targets
  end

  # this will change orders
  def try_to_occupied(ant, dir, orders)
    new_loc = ant.towards(dir)
    unless new_loc.occupied? || planed_location?(new_loc, orders)
      orders[ant] = dir
      return true
    end
    false
  end

  def planed_location?(loc, orders)
    orders.map { |ant, dir| ant.towards(dir) }.include?(loc)
  end

end

####################################
class FarmerTactics < TacticsBase
  attr_reader :aimed_foods

  def update_orders(orders)
    distances = distances_for(@ai.my_ants, @ai.foods)
    @aimed_foods = do_locate(distances, orders) # orders changed
  end
end


####################################
class HillsAttackerTactics < TacticsBase
end

####################################
class ExplorerTactics < TacticsBase
  def update_orders(orders)
    free_ants = @ai.my_ants - orders.keys
    unseen_distances = distances_for(free_ants, @unseen)

    do_locate(unseen_distances, orders)
  end
end

####################################
class NotBlockingHillTactics < TacticsBase
  def update_orders(orders)
    @ai.my_ants_in_hill.each do |ant|
      unless @aimed_foods.values.include?(ant)
        [:N, :S, :W, :E].shuffle.each do |dir|
          if try_to_occupied(ant, dir, orders)
            break
          end
        end
      end
    end
  end

end

