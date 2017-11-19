# frozen_string_literal: true

class TransferLane
  def initialize(window, home_planet, destination_planet)
    @window = window
    @home_planet = home_planet
    @destination_planet = destination_planet
  end

  def update
    transfer_on_click
  end

  def draw
    draw_lane
  end

  private

  def transfer_on_click
    #
  end

  def draw_lane
    # puts Gosu.angle(x1, y1, x2, y2)

    #red = Gosu::Color::RED
    #red.send(:alpha=, 2)
    #@window.draw_quad(100, 100, red, 180, 120, 0xffffffff, 120, 180, 0xffffffff, 200, 200, 0xffffffff, 1)

    @window.draw_line(@home_planet.x_center,
                      @home_planet.y_center,
                      Gosu::Color::GREEN,
                      @destination_planet.x_center,
                      @destination_planet.y_center,
                      Gosu::Color::RED,
                      z = 1)
  end
end
