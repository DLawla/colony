# frozen_string_literal: true

require './lib/modules/has_shape'

class TransferLane
  include HasShape

  attr_accessor :shape

  WIDTH_UNSELECTED = 10
  WIDTH_SELECTED = 30
  COLOR_FRIENDLY = 0x70_00ff00
  COLOR_ENEMY = 0x70_ff0000
  COLOR_TRANSPARENT = 0x00_808080

  def initialize(window, home_planet, destination_planet)
    @window = window
    @home_planet = home_planet
    @destination_planet = destination_planet

    initialize_bearing
    initialize_body
  end

  def update
    transfer_on_click
  end

  def draw
    draw_lane
  end

  def mouse_over
    puts 'mouse over!'
  end

  private

  def initialize_bearing
    @bearing = Gosu.angle(@destination_planet.x_center,
                          @destination_planet.y_center,
                          @home_planet.x_center,
                          @home_planet.y_center)
  end

  def initialize_body
    body = CP::Body.new(1, 1)
    shape_array = [CP::Vec2.new(-WIDTH_SELECTED/2, 0),
                   CP::Vec2.new(-WIDTH_SELECTED/2, lane_distance),
                   CP::Vec2.new(WIDTH_SELECTED/2, lane_distance),
                   CP::Vec2.new(WIDTH_SELECTED/2, 0)]
    @shape = CP::Shape::Poly.new(body, shape_array, CP::Vec2.new(0, 0))
    @shape.sensor = true
    @shape.collision_type = :transfer_lane
    @window.space.add_body(body)
    @window.space.add_shape(@shape)

    @shape.body.p = CP::Vec2.new(@home_planet.x_center, @home_planet.y_center) # position
    @shape.body.v = CP::Vec2.new(0.0, 0.0)
    # Offset added b/c shape array above is drawn in a coordinate system w/ y postive. Not
    # sure why the offset below is 90 degrees, however.
    @shape.body.a = Math::PI/2 + @bearing.gosu_to_radians
    @shape.object = self
  end

  def transfer_on_click
    #
  end

  def draw_lane
    Gosu.rotate(@bearing, @home_planet.x_center, @home_planet.y_center) do
      # drawing two touching quads, so can blend colors such that is transparent on the sides, and solid in the middle
      @window.draw_quad(@home_planet.x_center - WIDTH_UNSELECTED/2, @home_planet.y_center + lane_distance, lane_border_color,
                        @home_planet.x_center, @home_planet.y_center + lane_distance, lane_color,
                        @home_planet.x_center - WIDTH_UNSELECTED/2, @home_planet.y_center, lane_border_color,
                        @home_planet.x_center, @home_planet.y_center, lane_color,
                        1)
      @window.draw_quad(@home_planet.x_center, @home_planet.y_center + lane_distance, lane_color,
                        @home_planet.x_center + WIDTH_UNSELECTED/2, @home_planet.y_center + lane_distance, lane_border_color,
                        @home_planet.x_center, @home_planet.y_center, lane_color,
                        @home_planet.x_center + WIDTH_UNSELECTED/2, @home_planet.y_center, lane_border_color,
                        1)
    end

    debug_draw_shape(shape)
  end

  def lane_distance
    @distance ||= Gosu.distance(@home_planet.x_center,
                                @home_planet.y_center,
                                @destination_planet.x_center,
                                @destination_planet.y_center)
  end

  def lane_color
    @lane_color ||= @home_planet.faction == @destination_planet.faction ? COLOR_FRIENDLY : COLOR_ENEMY
  end

  def lane_border_color
    COLOR_TRANSPARENT
  end
end
