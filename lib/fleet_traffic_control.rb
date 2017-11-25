# frozen_string_literal: true

require './lib/fleet'

class FleetTrafficControl
  def send_fleet(starting_planet, destination_planet, percentage_leaving)
    return unless able_to_send?(starting_planet, destination_planet)
    load_and_send_fleet starting_planet, destination_planet, percentage_leaving
  end

  private

  def able_to_send?(starting_planet, destination_planet)
    starting_planet.can_transfer_to?(destination_planet)
  end

  def load_and_send_fleet starting_planet, destination_planet, percentage_leaving
    percentage_leaving = percentage_leaving.clamp(1, 100).to_f
    transferring_population = starting_planet.population * (percentage_leaving/100)
    transferring_population = [starting_planet.population - 10, transferring_population].min

    $window.add_entities([Fleet.new(starting_planet, destination_planet, transferring_population)])
    starting_planet.population -= transferring_population
    destination_planet.fleet_inbound
  end
end