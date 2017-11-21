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

  def teardown
    #
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
      disembark_population
      @window.destroy_entities([self])
    end
  end

  def travelled_distance
    @window.delta * @velocity
  end

  def image_offset
    @image_offset ||= -BASE_IMAGE_SIZE/2
  end

  def disembark_population
    if faction == @destination_planet.faction
      @destination_planet.population += @population
    else
      resolve_combat
    end
  end

  def resolve_combat
    if @destination_planet.population > @population
      @destination_planet.population -= @population
    elsif @destination_planet.population == @destination_planet
      @destination_planet.population = 1
    else
      @destination_planet.change_faction_to faction
      @destination_planet.population = @population - @destination_planet.population
    end
  end
end
