# frozen_string_literal: true

require './lib/helpers/circle'
include Math

class Planet
  attr_accessor :x, :y
  BASE_IMAGE_SIZE = 300
  BASE_SELECTION_SIZE = 300

  def initialize(window, args = {})
    @window = window
    @x = args[:x]
    @y = args[:y]

    @selected = false

    if args[:random]
      @size = @width = rand(30..90)
    else
      @size = @width = 60
    end

    @population = 1
    @max_population = @size * 100

    image
    selection_image
    @image_image_ratio = @width.to_f/BASE_IMAGE_SIZE.to_f
    @selection_image_ratio = @image_image_ratio * 3
    selection_image_offset

    @selection_diameter = @width + 10
    @population_font = Gosu::Font.new(@window, 'Courier', 15)
  end

  def draw
    image.draw(@x, @y, 5, @image_image_ratio, @image_image_ratio)
    draw_selection_image

    @population_font.draw("#{@population.to_i}", @x, @y, 7)
    # TODO, on hover over lighten image
  end

  def update
    udpate_selection
    update_population
  end

  private

  def image
    @image ||= Gosu::Image.new("media/planets/planet_#{rand(15) + 1}.png")
  end

  def selection_image
    @selection_image ||= Gosu::Image.new("media/selection.png")
  end

  def draw_selection_image
    if @selected
      selection_image.draw(@x + selection_image_offset,
                           @y + selection_image_offset,
                           0,
                           @selection_image_ratio,
                           @selection_image_ratio)
    end
  end

  def selection_image_offset
    @selection_image_offset ||= ((BASE_IMAGE_SIZE * @image_image_ratio) -
                                (BASE_SELECTION_SIZE * @selection_image_ratio)) * 0.5
  end

  def udpate_selection
    if @window.button_down? Gosu::MsLeft
      @selected = within_planet? @window.mouse_x, @window.mouse_y
    end
  end

  def update_population
    # Follow logistic map function to grow until a max population
    rate = 0.005
    @population = @population * E ** (rate * (1 - (@population/@max_population)))
  end

  def within_planet? x, y
    x.between?(@x, @x + @width) && y.between?(@y, @y + @width)
  end
end