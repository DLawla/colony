# frozen_string_literal: true

require './lib/modules/has_faction'
require './lib/fleet_traffic_control'

class BaseContender
  include HasFaction

  def initialize(faction:)
    assign_faction faction
    @last_action_at = Time.now
  end

  def update
    raise 'Opponent class must define an #update method'
  end

  def draw
    # Nothing should be placed here
  end

  def human?
    false
  end

  def artificial_intelligence?
    !human?
  end
end
