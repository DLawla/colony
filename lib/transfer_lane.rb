# frozen_string_literal: true

class TransferLane
  WIDTH_UNSELECTED = 10

  COLOR_FRIENDLY = 0x70_00ff00
  COLOR_ENEMY = 0x70_ff0000
  COLOR_TRANSPARENT = 0x00_808080

  def initialize(window, home_planet, destination_planet)
    @window = window
    @home_planet = home_planet
    @destination_planet = destination_planet

    intialize_bearing
  end

  def update
    transfer_on_click
    contains?(@window.mouse_x, @window.mouse_y)
  end

  def draw
    draw_lane
  end

  def contains?(x, y)
    # y = mx + b
    # y1 = mx1 + b
    # y2 = mxx2 + b
    # m = (y1 - b)/x1
    # => (y2 - b)/x2
    # y2/x2 = y1x2/x1 - bx2/x1 + b/x2
  end

  private

  def intialize_bearing
    @bearing = Gosu.angle(@destination_planet.x_center,
                          @destination_planet.y_center,
                          @home_planet.x_center,
                          @home_planet.y_center)
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
