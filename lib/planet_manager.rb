# frozen_string_literal: true

require './lib/planet'

class PlanetManager
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
        if planet_being_selected
          if selected_planet.can_transfer_to?(planet_being_selected)
            selected_planet.transfer_population_to(planet_being_selected)
            planet_being_selected.receive_population
            remove_planet_selection
          end
        else
          remove_planet_selection
        end
      else
        if planet_being_selected && planet_being_selected.friendly?
          planet_being_selected.select
        else
          remove_planet_selection
        end
      end
    end
  end

  def selected_planet
    @window.planets.select(&:selected?).first
  end

  def planet_being_selected
    @window.planets.select { |planet| planet.within_planet?(@window.mouse_x, @window.mouse_y) }.first
  end

  def remove_planet_selection
    @window.planets.each(&:unselect)
  end

  def assign_planet_selection_to planet
    planet.select
  end

  def other_planet_being_selected
    @window.planets.reject { |planet| planet == self}.each do |planet|
      return planet if planet.within_planet?(@window.mouse_x, @window.mouse_y)
    end
    nil
  end
end
