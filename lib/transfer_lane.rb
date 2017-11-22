# frozen_string_literal: true

require './lib/modules/has_shape'

class TransferLane
  include HasShape

  attr_accessor :home_planet, :destination_planet

  WIDTH_UNSELECTED = 10
  WIDTH_SELECTED = 30
  HEIGHT_SELECTED_TICK = 10
  COLOR_FRIENDLY = 0x70_00ff00
  COLOR_ENEMY = 0x70_ff0000
  COLOR_SELECTED = 0x70_0000ff
  COLOR_SELECTED_TICK = 0x70_ff00ff
  COLOR_TRANSPARENT = 0x00_808080

  def initialize(selection_manager, home_planet, destination_planet)
    @selection_manager = selection_manager
    @home_planet = home_planet
    @destination_planet = destination_planet

    @selected = false

    initialize_bearing
    initialize_selection_vertices
  end

  def update
    #
  end

  def draw
    draw_lane
  end

  def within?(x, y)
    # within selectable region of transfer lane
    # should include within lane and both of its planets
  end

  def self.selected
    $window.transfer_lanes.select(&:selected?).first
  end

  def self.unselect_all
    $window.transfer_lanes.each(&:unselect)
  end

  def select
    @selected = true
  end

  def selected?
    @selected
  end

  def unselect
    @selected = false
  end

  def percentage_selected
    (([mouse_distance_from_home, lane_distance].min)/lane_distance) * 100
  end

  private

  def initialize_bearing
    @bearing = Gosu.angle(@destination_planet.x_center,
                          @destination_planet.y_center,
                          @home_planet.x_center,
                          @home_planet.y_center)
  end

  def initialize_selection_vertices
    @selection_vertices = [
        {x: @home_planet.x_center + Gosu.offset_x(@bearing - 90, WIDTH_SELECTED/2),
         y: @home_planet.y_center + Gosu.offset_y(@bearing - 90, WIDTH_SELECTED/2)},
        {x: @destination_planet.x_center + Gosu.offset_x(@bearing - 90, WIDTH_SELECTED/2),
         y: @destination_planet.y_center + Gosu.offset_y(@bearing - 90, WIDTH_SELECTED/2)},
        {x: @destination_planet.x_center + Gosu.offset_x(@bearing + 90, WIDTH_SELECTED/2),
         y: @destination_planet.y_center + Gosu.offset_y(@bearing + 90, WIDTH_SELECTED/2)},
        {x: @home_planet.x_center + Gosu.offset_x(@bearing + 90, WIDTH_SELECTED/2),
         y: @home_planet.y_center + Gosu.offset_y(@bearing + 90, WIDTH_SELECTED/2)},
    ]
  end

  def draw_lane
    Gosu.rotate(@bearing, @home_planet.x_center, @home_planet.y_center) do
      # drawing two touching quads, so can blend colors such that is transparent on the sides, and solid in the middle
      $window.draw_quad(@home_planet.x_center - WIDTH_UNSELECTED/2, @home_planet.y_center + lane_distance, lane_border_color,
                        @home_planet.x_center, @home_planet.y_center + lane_distance, lane_color,
                        @home_planet.x_center - WIDTH_UNSELECTED/2, @home_planet.y_center, lane_border_color,
                        @home_planet.x_center, @home_planet.y_center, lane_color,
                        1)
      $window.draw_quad(@home_planet.x_center, @home_planet.y_center + lane_distance, lane_color,
                        @home_planet.x_center + WIDTH_UNSELECTED/2, @home_planet.y_center + lane_distance, lane_border_color,
                        @home_planet.x_center, @home_planet.y_center, lane_color,
                        @home_planet.x_center + WIDTH_UNSELECTED/2, @home_planet.y_center, lane_border_color,
                        1)
    end

    if selected?
      # drawing two touching quads, so can blend colors such that is transparent on the sides, and solid in the middle
      $window.draw_quad(@selection_vertices[0][:x], @selection_vertices[0][:y], lane_border_color,
                        @selection_vertices[1][:x], @selection_vertices[1][:y], lane_border_color,
                        @destination_planet.x_center, @destination_planet.y_center, COLOR_SELECTED,
                        @home_planet.x_center, @home_planet.y_center, COLOR_SELECTED,
                        1)
      $window.draw_quad(@home_planet.x_center, @home_planet.y_center, COLOR_SELECTED,
                        @destination_planet.x_center, @destination_planet.y_center, COLOR_SELECTED,
                        @selection_vertices[2][:x], @selection_vertices[2][:y], lane_border_color,
                        @selection_vertices[3][:x], @selection_vertices[3][:y], lane_border_color,
                        1)

      # draw quad @ rough location of where mouse is hover over
      Gosu.rotate(@bearing, @home_planet.x_center, @home_planet.y_center) do
        Gosu.translate(0, mouse_distance_from_home) do
          $window.draw_quad(@home_planet.x_center - WIDTH_SELECTED/2, @home_planet.y_center - HEIGHT_SELECTED_TICK/2, COLOR_SELECTED_TICK,
                            @home_planet.x_center - WIDTH_SELECTED/2, @home_planet.y_center + HEIGHT_SELECTED_TICK/2, COLOR_SELECTED_TICK,
                            @home_planet.x_center + WIDTH_SELECTED/2, @home_planet.y_center + HEIGHT_SELECTED_TICK/2, COLOR_SELECTED_TICK,
                            @home_planet.x_center + WIDTH_SELECTED/2, @home_planet.y_center - HEIGHT_SELECTED_TICK/2, COLOR_SELECTED_TICK,
                            1)
        end
      end
    end
  end

  def lane_distance
    @distance ||= Gosu.distance(@home_planet.x_center,
                                @home_planet.y_center,
                                @destination_planet.x_center,
                                @destination_planet.y_center)
  end

  def mouse_distance_from_home
    @mouse_distance_from_home = Gosu.distance(@home_planet.x_center,
                                              @home_planet.y_center,
                                              $window.mouse_x,
                                              $window.mouse_y)
  end

  def bearing_line
    @bearing_line ||= [m: @bearing, b: bearing_line_y_intercept]
  end

  def bearing_line_y_intercept
    # b = y_center - tan(bearing) * x_center
    @bearing_line_y_intercept ||= @home_planet.y_center - Math::tan(@bearing.gosu_to_radians) * @home_planet.x_center
  end

  def lane_color
    @lane_color ||= @home_planet.faction == @destination_planet.faction ? COLOR_FRIENDLY : COLOR_ENEMY
  end

  def lane_border_color
    COLOR_TRANSPARENT
  end
end
