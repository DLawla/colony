# frozen_string_literal: true

require './lib/modules/has_shape'

class TransferLane
  include HasShape

  attr_accessor :home_planet, :destination_planet
  attr_reader :id

  WIDTH_UNSELECTED = 10
  WIDTH_SELECTED = 30
  HEIGHT_SELECTED_TICK = 10

  def initialize(selection_manager, home_planet, destination_planet)
    @selection_manager = selection_manager
    @home_planet = home_planet
    @destination_planet = destination_planet

    @selected = false

    @id = rand(0..1000)

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
    # if a horizontal line starting from this point is cast in any direction (here using y constant line):
    # and has the following number of intersections w/ selection box boundary:
    #   0: it is not within
    #   odd number: it is within
    #   even number: is not within

    # count intersection of horizontal line starting from point w/ selection box
    intersections = 0
    number_of_vertices = @selection_vertices.length

    @selection_vertices.each_with_index do |vertex, i|
      next_vertex = @selection_vertices[(i + 1)%number_of_vertices]
      x_intersection = x_on_line_from_points_at(y, vertex[:x], vertex[:y], next_vertex[:x], next_vertex[:y])

      # check:
      # 1) smallest given x < x_intersection
      # 2) given y is between the vertices
      if (x < x_intersection) && (y.between?(vertex[:y], next_vertex[:y]) || y.between?(next_vertex[:y], vertex[:y]))
        intersections += 1
      end
    end

    !intersections.zero? && intersections.odd?
  end

  def self.selected
    $window.transfer_lanes.select(&:selected?)
    selected_lanes = $window.transfer_lanes.select(&:selected?)
    return selected_lanes.first if selected_lanes
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
    # Draw thin transfer lane quad
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

    # Draw wider transfer lane quad, denoting the selection
    if selected?
      # drawing two touching quads, so can blend colors such that is transparent on the sides, and solid in the middle
      $window.draw_quad(@selection_vertices[0][:x], @selection_vertices[0][:y], lane_border_color,
                        @selection_vertices[1][:x], @selection_vertices[1][:y], lane_border_color,
                        @destination_planet.x_center, @destination_planet.y_center, lane_color,
                        @home_planet.x_center, @home_planet.y_center, lane_color,
                        1)
      $window.draw_quad(@home_planet.x_center, @home_planet.y_center, lane_color,
                        @destination_planet.x_center, @destination_planet.y_center, lane_color,
                        @selection_vertices[2][:x], @selection_vertices[2][:y], lane_border_color,
                        @selection_vertices[3][:x], @selection_vertices[3][:y], lane_border_color,
                        1)

      # draw quad @ rough location of where mouse is hover over
      Gosu.rotate(@bearing, @home_planet.x_center, @home_planet.y_center) do
        Gosu.translate(0, mouse_distance_from_home) do
          $window.draw_quad(@home_planet.x_center - WIDTH_SELECTED/2, @home_planet.y_center - HEIGHT_SELECTED_TICK/2, lane_color,
                            @home_planet.x_center - WIDTH_SELECTED/2, @home_planet.y_center + HEIGHT_SELECTED_TICK/2, lane_color,
                            @home_planet.x_center + WIDTH_SELECTED/2, @home_planet.y_center + HEIGHT_SELECTED_TICK/2, lane_color,
                            @home_planet.x_center + WIDTH_SELECTED/2, @home_planet.y_center - HEIGHT_SELECTED_TICK/2, lane_color,
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
    @lane_color ||= @home_planet.faction == @destination_planet.faction ? Colony::COLOR_FRIENDLY : Colony::COLOR_ENEMY
  end

  def lane_border_color
    Colony::COLOR_TRANSPARENT
  end

  def x_on_line_from_points_at(y, x_1, y_1, x_2, y_2)
    # if x's are equal, then vertical line, so return any x
    return x_1 if x_1 == x_2

    # y = mx + b = > x = (y-b)/m
    m = (y_1 - y_2) / (x_1 - x_2)
    b = y_1 - (m * x_1 )
    (y - b)/m
  end
end
