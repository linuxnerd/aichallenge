$:.unshift File.dirname($0)
require 'ants.rb'

ai=AI.new

ai.setup do |ai|
	# your setup code here, if any
end


def do_move_direction ant, dir
	new_loc = ant.square.neighbor(dir)
	if !@orders.include?(new_loc) && new_loc.land?
		ant.order dir
		@orders[new_loc] = ant.square
		return true
	end
	return false
end

ai.run do |ai|
	# your turn code here
	@orders = {}

	ai.my_ants.each do |ant|
		# try to go north, if possible; otherwise try east, south, west.
		[:N, :E, :S, :W].each do |dir|
			break if do_move_direction(ant, dir)
		end
	end
end