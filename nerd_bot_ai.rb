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
    
    def move_ants_to(orders)
      orders.each do |ant, dir|
        ant.order dir
      end
    end

    def next_directions
      # orders is hash like {:ant => :W}
      {}.tap do |orders|
        # gathering food
        farmer = FarmerStrategy.new(@ai)
        farmer.update_orders(orders)
        
        # enemy hills
        update_enemy_hills

        # occupied enemy's hills
        attacker = HillsAttackerStrategy.new(@ai, '', '', @enemy_hills)
        attacker.update_orders(orders)

        # not blocking hill
        aimed_foods = farmer.aimed_foods
        not_blocking = NotBlockingHillStrategy.new(@ai, '', aimed_foods)
        not_blocking.update_orders(orders)

        # update unseen map
        update_unseen

        # explorer unseen
        explorer = ExplorerStrategy.new(@ai, @unseen)
        explorer.update_orders(orders)
      end
    end

    def update_enemy_hills
      @enemy_hills.concat(@ai.enemy_hills).uniq!
    end

    def update_unseen
      @unseen.delete_if do |square|
        @ai.my_ants.any? { |ant| ant.see?(square) }
      end
    end
end


####################################
class StrategyBase
  include Utils

  def initialize(ai, unseen='', aimed_foods='', enemy_hills='')
    @ai = ai
    @row_max = @ai.settings[:rows]
    @col_max = @ai.settings[:cols]
    @unseen = unseen
    @aimed_foods = aimed_foods
    @enemy_hills = enemy_hills

    @logger = Logger.new(LOG_FILE)

  end

  # Return directions like [:N,:E]
  def directions_for(from, to)
    [].tap do |result|
      if (from.row - to.row).abs > @row_max/2
        result << :N if from.row < to.row
        result << :S if from.row > to.row
      else
        result << :S if from.row < to.row
        result << :N if from.row > to.row
      end

      if (from.col - to.col).abs > @col_max/2
        result << :W if from.col < to.col
        result << :E if from.col > to.col
      else
        result << :E if from.col < to.col
        result << :W if from.col > to.col
      end
    end
  end

  # Return distances like [{:distance=>5.0, :target=>food, :ant=>ant}]
  def distances_for(ants, targets)
    type = case self.class.to_s
           when 'FarmerStrategy' then :farmer
           when 'HillsAttackerStrategy' then :attacker
           when 'ExplorerStrategy' then :explorer
           end
    [].tap do |distances|
      ants.each do |ant|
        distances.concat targets.map { |target| {:distance=>spherical_distance(ant, target, @row_max, @col_max), :ant=>ant, :target=>target, :type => type} }
      end
    end
  end

  # Return { :food => ant }, only NotBlockingHillStrategy needs
  def do_locate(distances, orders)
    aimed_targets = {}
    sorted_distances = distances.sort_by { |hash| hash[:distance] }

    sorted_distances.each do |move|
      ant = move[:ant]
      target = move[:target]
      unless aimed_targets.keys.include?(target) || aimed_targets.values.include?(ant)
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
class FarmerStrategy < StrategyBase
  attr_reader :aimed_foods

  def update_orders(orders)
    distances = distances_for(@ai.my_ants, @ai.foods)
    @aimed_foods = do_locate(distances, orders) # orders changed
  end
end


####################################
class HillsAttackerStrategy < StrategyBase
  def update_orders(orders)
    distances = distances_for(@ai.my_ants, @enemy_hills)
    do_locate(distances, orders)
  end
end

####################################
class ExplorerStrategy < StrategyBase
  def update_orders(orders)
    free_ants = @ai.my_ants - orders.keys
    unseen_distances = distances_for(free_ants, @unseen)

    do_locate(unseen_distances, orders)
  end
end

####################################
class NotBlockingHillStrategy < StrategyBase
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

