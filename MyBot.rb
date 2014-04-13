$:.unshift File.dirname($0)
require 'ants.rb'
require 'nerd_bot_ai.rb'

#################################
#declarations
#################################
ai            = AI.new
nerd_bot      = NerdBotAi.new
# end of declarations


ai.setup do |ai|
  # your setup code here, if any
  nerd_bot.setup(ai)
end

ai.run do |ai|
  # your turn code here
  nerd_bot.next_step
end