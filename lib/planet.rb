require './lib/helpers/circle'

class Planet
  attr_accessor :x, :y

  def initialize(window)
    @window = window

    @image = Gosu::Image.new('media/planets/planet_1.png')
    @x = 200
    @y = 200
    @width = 60
    @height = 60

    @selected = false

    @circle = Gosu::Image.new(Circle.new(50, 200, 200, 200))
  end

  def draw
    @image.draw(@x, @y, 5, 0.1, 0.1)

    @circle.draw(100, 100, 0)

    # on hover over, dim the opacity of the planet image
  end

  def update
    planet_clicked?
  end

  private

  def image
    @image ||= Gosu::Image.new("media/planets/planet_#{rand(15) + 1}.png")
  end

  def planet_clicked?
    # Gosu::MsLeft && mouse_x
    if @window.button_down? Gosu::MsLeft
      if within_planet? @window.mouse_x, @window.mouse_y
        #
      else
        #
      end
    end
  end

  def within_planet? x, y
    x.between?(@x, @x + @width) && y.between?(@y, @y + @height)
  end
end