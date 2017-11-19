# frozen_string_literal: true

require './lib/planet'
require './lib/fleet'
require './lib/transfer_lane'

class SelectionManager
  def initialize(window)
    @window = window
  end

  def update
    update_planet_selection
  end

  def draw
    #
  end

  private

  def update_planet_selection
    if @window.button_down_one_shot? Gosu::MsLeft
      puts 'button down'

      if selected_planet
        if planet_moused_over
          if selected_planet.can_transfer_to?(planet_moused_over)
            load_and_send_fleet selected_planet, planet_moused_over, 100
            remove_planet_selection
          end
        else
          remove_planet_selection
        end
      else
        if planet_moused_over && planet_moused_over.friendly?
          add_planet_selection planet_moused_over
        else
          remove_planet_selection
        end
      end
    end
  end

  def add_planet_selection planet
    planet.select
    create_transfer_lanes_for planet
  end

  def create_transfer_lanes_for planet_source
    transferrable_planets = @window.planets.select { |planet| planet_source.can_transfer_to? planet }
    transferrable_planets.each do |transferrable_planet|
      @window.add_entities([TransferLane.new(@window, planet_source, transferrable_planet)])
    end
  end

  def selected_planet
    @window.planets.select(&:selected?).first
  end

  def planet_moused_over
    @window.planets.select { |planet| planet.within_planet?(@window.mouse_x, @window.mouse_y) }.first
  end

  def remove_planet_selection
    @window.planets.each(&:unselect)
    @window.destroy_entities(@window.transfer_lanes)
  end

  def assign_planet_selection_to planet
    planet.select
  end

  def load_and_send_fleet starting_planet, destination_planet, percentage_leaving
    percentage_leaving = percentage_leaving.clamp(1, 100)
    transfering_population = starting_planet.population * (percentage_leaving/100)
    transfering_population = [starting_planet.population - 10, transfering_population].min

    @window.add_entities([Fleet.new(@window, starting_planet, destination_planet, transfering_population)])
    starting_planet.population -= transfering_population
  end
end
