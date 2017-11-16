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
    draw_transfer_lanes
  end

  private

  def update_planet_selection
    if @window.button_down_one_shot? Gosu::MsLeft
      puts 'button down'

      if selected_planet
        if planet_moused_over
          if selected_planet.can_transfer_to?(planet_moused_over)
            selected_planet.transfer_population_to(planet_moused_over)
            planet_moused_over.receive_population
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
    planet_destination = planet_moused_over
    if planet_source && planet_destination && planet_source.can_transfer_to?(planet_destination)
      draw_lanes(planet_source.x_center,
                 planet_source.y_center,
                 planet_destination.x_center,
                 planet_destination.y_center)
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
  end

  def assign_planet_selection_to planet
    planet.select
  end

  def draw_lanes(x1, y1, x2, y2)
    # calculate the angle between the two planets
    # using some trig, draw to parallel lines, of a fixed separating distance, between the two planets

    # find angle between: Math.tan(y1 - y2/x1 - x2)
    # ...
    # profit

    x_difference = (x2 - x1).to_f
    y_difference = (y1 - y2).to_f
    puts "x difference: #{x_difference}"
    puts "y difference: #{y_difference}"
    puts (Math.atan(x_difference/y_difference) * 360 / (2 * Math::PI)) # radians to degrees

    @window.draw_line(x1,
                      y1,
                      Gosu::Color::RED,
                      x2,
                      y2,
                      Gosu::Color::GREEN,
                      z = 1)
  end
end
