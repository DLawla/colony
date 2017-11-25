# frozen_string_literal: true

require './lib/modules/has_faction'
require './lib/fleet_traffic_control'

class BaseOpponent
  include HasFaction

  def initialize
    assign_faction :enemy
  end

  def update
    raise 'Opponent class must define an #update method'
  end

  def draw
    # Nothing should be placed here
  end
end