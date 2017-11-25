# frozen_string_literal: true

require './lib/opponents/base_opponent'

module Opponents
  class V1 < BaseOpponent
    # Inputs
    #
    # All planets: $window.planets => array of planets
    # All my planets: Planet.of_faction(faction)

    # Outputs
    # FleetTrafficControl.send_fleet(starting_planet, destination_planet, percentage_leaving)

    def update
      puts "I'm Mr MeeSeeks!"
      puts 'Look at all my planets:'
      puts Planet.of_faction(faction)
    end
  end
end
