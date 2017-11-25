# frozen_string_literal: true

require './lib/opponents/base_opponent'

module Opponents
  class V1 < BaseOpponent
    # Inputs
    # All planets: $window.planets => array of planets
    # All of my planets: Planet.of_faction(faction)

    # Outputs
    # Launch a fleet to another planet:
    #    => FleetTrafficControl.new.send_fleet(starting_planet, destination_planet, percentage_leaving)


    # 1.0 Strategy
    # If your planet is significantly above population sweet spot, and an adjacent friendly planet is not,
    #   transfer to it
    # If your planet ever has (20% or 500 more population) OR more than the max population of an
    #   adjacent enemy, transfer to it

    def update
      if @last_action_at < Time.now - 1
        reinforce_friendly_planets
        attack_adjacent_planets

        @last_action_at = Time.now
      end
    end

    private

    def reinforce_friendly_planets
      Planet.of_faction(faction).each do |planet|
        next if planet.population < population_sweet_spot(planet)
        planet.transferrable_planets.detect do |other_planet|
          if other_planet.faction == faction &&
              planet.population > population_sweet_spot(planet) &&
              other_planet.population < population_sweet_spot(other_planet) &&
              !fleets_on_the_way?(planet, other_planet)
            FleetTrafficControl.new.send_fleet(planet, other_planet, 20)
            break
          end
        end
      end
    end

    def attack_adjacent_planets
      Planet.of_faction(faction).each do |planet|
        planet.transferrable_planets.detect do |other_planet|
          if other_planet.faction != faction && other_planet.population < planet.population
            FleetTrafficControl.new.send_fleet(planet, other_planet, 100)
            break
          end
        end
      end
    end

    def population_sweet_spot(planet)
      planet.max_population/2
    end

    def fleets_on_the_way?(starting_planet, destination_planet)
      $window.fleets.select do |fleet|
        fleet.home_planet == starting_planet && fleet.destination_planet == destination_planet
      end.any?
    end
  end
end
