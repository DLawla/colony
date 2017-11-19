# frozen_string_literal: true

class TransferLane
  def initialize(window, home_planet, destination_planet)
    @window = window
    @home_planet = home_planet
    @destination_planet = destination_planet

    initialize_coordinates
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

  def initialize_coordinates
    bearing = Gosu.angle(@home_planet.x_center,
                         @home_planet.y_center,
                         @destination_planet.x_center,
                         @destination_planet.y_center)
    puts bearing
    @coordinates = [{x: 100, y: 100}, {x: 160, y: 140}, {x: 140, y: 160}, {x: 200, y: 200}]
  end

  def transfer_on_click
    #
  end

  def draw_lane
    # puts Gosu.angle(x1, y1, x2, y2)

    red = Gosu::Color::RED
    red.send(:alpha=, 2)

    @window.draw_quad(@coordinates[0][:x],
                      @coordinates[0][:y],
                      red,
                      @coordinates[1][:x],
                      @coordinates[1][:y],
                      red,
                      @coordinates[2][:x],
                      @coordinates[2][:y],
                      red,
                      @coordinates[3][:x],
                      @coordinates[3][:y],
                      red,
                      1)

    @window.draw_line(@home_planet.x_center,
                      @home_planet.y_center,
                      Gosu::Color::GREEN,
                      @destination_planet.x_center,
                      @destination_planet.y_center,
                      Gosu::Color::RED,
                      z = 1)
  end
end
