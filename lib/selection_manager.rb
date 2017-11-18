# frozen_string_literal: true

require './lib/planet'
require './lib/fleet'

class SelectionManager
  def initialize(window)
    @window = window
  end

  def update
    update_planet_selection
  end

  def draw
    draw_transfer_lanes
    draw_moused_over_transfer_lane
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
          planet_moused_over.select
        else
          remove_planet_selection
        end
      end
    end
  end

  def draw_transfer_lanes
    # If a planet is selected, and the mouse is hovering over another planet which population can be transferred to,
    # then draw a couple lines (making a lane), between the two planets
    planet_source = selected_planet
    if planet_source = selected_planet
      transferrable_planets = @window.planets.select { |planet| planet_source.can_transfer_to? planet }
      transferrable_planets.each do |transferrable_planet|
        draw_transfer_lane(planet_source.x_center,
                           planet_source.y_center,
                           transferrable_planet.x_center,
                           transferrable_planet.y_center)
      end
    end
  end

  def draw_moused_over_transfer_lane
    # if user is drawing at all over a transfer lane, somehow draw
  end

  def selected_planet
    @window.planets.select(&:selected?).first
  end

  def planet_moused_over
    @window.planets.select { |planet| planet.within_planet?(@window.mouse_x, @window.mouse_y) }.first
  end

  def remove_planet_selection
    @window.planets.each(&:unselect)
  end

  def assign_planet_selection_to planet
    planet.select
  end

  def draw_transfer_lane(x1, y1, x2, y2)
    puts Gosu.angle(x1, y1, x2, y2)

    red = Gosu::Color::RED
    red.send(:alpha=, 2)
    @window.draw_quad(100, 100, red, 180, 120, 0xffffffff, 120, 180, 0xffffffff, 200, 200, 0xffffffff, 1)


    @window.draw_line(x1,
                      y1,
                      Gosu::Color::GREEN,
                      x2,
                      y2,
                      Gosu::Color::RED,
                      z = 1)
  end

  def load_and_send_fleet starting_planet, destination_planet, percentage_leaving
    percentage_leaving = percentage_leaving.clamp(1, 100)
    transfering_population = starting_planet.population * (percentage_leaving/100)
    transfering_population = [starting_planet.population - 10, transfering_population].min

    @window.add_entities([Fleet.new(@window, starting_planet, destination_planet, transfering_population)])
    starting_planet.population -= transfering_population
  end
end
