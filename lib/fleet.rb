# frozen_string_literal: true

require './lib/planet'

class Fleet
  include HasFaction

  BASE_IMAGE_SIZE = 50

  def initialize(window, home_planet, destination_planet, population)
    @window = window
    @home_planet = home_planet
    @destination_planet = destination_planet
    @population = population

    assign_faction @home_planet.faction

    image

    calculate_starting_position

    @velocity = 60
    calculate_bearing
  end

  def update
    update_position
    disembark_if_arrived
  end

  def draw
    image.draw(@x + image_offset,
               @y + image_offset,
               10,
               1,
               1)
  end

  private

  def image
    @image ||= Gosu::Image.new("media/fleet.png")
  end

  def calculate_bearing
    @bearing= Gosu.angle(@home_planet.x_center,
                         @home_planet.y_center,
                         @destination_planet.x_center,
                         @destination_planet.y_center)
  end

  def calculate_starting_position
    @x = @home_planet.x_center
    @y = @home_planet.y_center
  end

  def update_position
    @x += Gosu.offset_x(@bearing, travelled_distance)
    @y += Gosu.offset_y(@bearing, travelled_distance)
  end

  def disembark_if_arrived
    if @destination_planet.within_planet? @x, @y
      @home_planet.transfer_population_to(@destination_planet)

      @window.destroy_entities([self])
    end
  end

  def travelled_distance
    @window.delta * @velocity
  end

  def image_offset
    @image_offset ||= -BASE_IMAGE_SIZE/0.5
  end
end
