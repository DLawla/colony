# frozen_string_literal: true

class TransferLane
  WIDTH_UNSELECTED = 20

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
    red = Gosu::Color::RED
    red.send(:alpha=, 75)

    Gosu.rotate(@bearing, @home_planet.x_center, @home_planet.y_center) do
      @window.draw_quad(@home_planet.x_center - WIDTH_UNSELECTED/2, @home_planet.y_center + lane_distance, red,
                        @home_planet.x_center + WIDTH_UNSELECTED/2, @home_planet.y_center + lane_distance, red,
                        @home_planet.x_center - WIDTH_UNSELECTED/2, @home_planet.y_center, red,
                        @home_planet.x_center + WIDTH_UNSELECTED/2, @home_planet.y_center, red,
                        1)
    end

    @window.draw_line(@home_planet.x_center,
                      @home_planet.y_center,
                      Gosu::Color::GREEN,
                      @destination_planet.x_center,
                      @destination_planet.y_center,
                      Gosu::Color::RED,
                      z = 1)
  end

  def lane_distance
    @distance ||= Gosu.distance(@home_planet.x_center,
                                @home_planet.y_center,
                                @destination_planet.x_center,
                                @destination_planet.y_center)
  end
end
