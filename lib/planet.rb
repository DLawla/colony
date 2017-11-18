# frozen_string_literal: true

require './lib/helpers/circle'
require './lib/modules/has_faction'
include Math

class Planet
  include HasFaction

  attr_accessor :x, :x_center, :y, :y_center, :selected, :population, :row
  BASE_IMAGE_SIZE = 300
  BASE_SELECTION_SIZE = 300
  MIN_PLANET_SIZE = 30
  MAX_PLANET_SIZE = 90
  DEFAULT_PLANET_SIZE = 90

  def initialize(window, args = {})
    @window = window
    @selected = false

    if args[:random] && args[:random] == true
      @size = @width = rand(MIN_PLANET_SIZE..MAX_PLANET_SIZE)
    else
      @size = @width = DEFAULT_PLANET_SIZE
    end

    @x_center = args[:x_center]
    @x = x_center - @size/2
    @y_center = args[:y_center]
    @y = y_center - @size/2
    @row = args[:row]

    if args[:unpopulated] && args[:unpopulated] == true
      @population = 0.0
    else
      @population = 10.0
    end

    @max_population = @size * 100

    assign_faction args[:faction]

    image
    selection_image
    @image_image_ratio = @width.to_f/BASE_IMAGE_SIZE.to_f
    @selection_image_ratio = @image_image_ratio * 3
    selection_image_offset

    @selection_diameter = @width + 10
    @population_font = Gosu::Font.new(@window, 'Courier', 15)
  end

  def update
    update_status
    update_population
  end

  def draw
    image.draw(@x, @y, 5, @image_image_ratio, @image_image_ratio)
    draw_selection_image
    draw_population
  end

  def within_planet?(x, y)
    x.between?(@x, @x + @width) && y.between?(@y, @y + @width)
  end

  def selected?
    @selected
  end

  def select
    @selected = true
  end

  def unselect
    @selected = false
  end

  def receive_population
    @receiving_started_at = Time.now
  end

  def finish_receiving_population
    @receiving_started_at = nil
  end

  def receiving_population?
    @receiving_started_at
  end

  def can_transfer_to?(other_planet)
    other_planet != self && (@row - other_planet.row).abs <= 1
  end

  private

  def image
    @image ||= Gosu::Image.new("media/planets/planet_#{rand(15) + 1}.png")
  end

  def selection_image
    @selection_image ||= Gosu::Image.new("media/selection.png")
  end

  def draw_selection_image
    if receiving_population?
      selection_image.draw(@x + selection_image_offset,
                           @y + selection_image_offset,
                           0,
                           @selection_image_ratio,
                           @selection_image_ratio,
                           @window.oscillating_color(Gosu::Color::GREEN)
      )
    elsif @selected
      selection_image.draw(@x + selection_image_offset,
                           @y + selection_image_offset,
                           0,
                           @selection_image_ratio,
                           @selection_image_ratio)
    end
  end

  def draw_population
    if friendly?
      color = Gosu::Color::GREEN
    elsif enemy?
      color = Gosu::Color::RED
    else
      color = Gosu::Color::YELLOW
    end
    @population_font.draw("#{@population.to_i}", @x, @y, 7, 1, 1, color)
  end

  def update_status
    if receiving_population?
      finish_receiving_population if (Time.now - @receiving_started_at > 0.5)
    end
  end

  def update_population
    # Follow logistic map function to grow until a max population
    rate = 0.005
    @population = @population * E ** (rate * (1 - (@population/@max_population)))
  end

  def selection_image_offset
    @selection_image_offset ||= ((BASE_IMAGE_SIZE * @image_image_ratio) -
        (BASE_SELECTION_SIZE * @selection_image_ratio)) * 0.5
  end
end