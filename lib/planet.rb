require './lib/helpers/circle'

class Planet
  attr_accessor :x, :y

  def initialize(window, x, y)
    @window = window

    image
    @x = x
    @y = y
    @width = 60
    @height = 60

    @selected = false

    @selection_radius = 38
    @circle = Gosu::Image.new(Circle.new(@selection_radius, 90, 90, 90))
  end

  def draw
    image.draw(@x, @y, 5, 0.2, 0.2)
    @circle.draw(@x + (@width/2 - @selection_radius), @y + (@height/2 - @selection_radius), 0) if @selected

    # TODO, on hover over lighten image
  end

  def update
    udpate_selection
  end

  private

  def image
    @image ||= Gosu::Image.new("media/planets/planet_#{rand(15) + 1}.png")
  end

  def udpate_selection
    if @window.button_down? Gosu::MsLeft
      @selected = within_planet? @window.mouse_x, @window.mouse_y
    end
  end

  def within_planet? x, y
    x.between?(@x, @x + @width) && y.between?(@y, @y + @height)
  end
end