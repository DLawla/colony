# frozen_string_literal: true

require './lib/helpers/circle'
require './lib/modules/has_faction'
include Math

class Planet
  include HasFaction

  attr_accessor :selected, :population
  attr_reader :x, :x_center, :y, :y_center, :row, :sector, :cell, :max_population
  BASE_IMAGE_SIZE = 300
  BASE_SELECTION_SIZE = 300
  MIN_PLANET_SIZE = 30
  MAX_PLANET_SIZE = 90
  DEFAULT_PLANET_SIZE = 90

  def initialize(args = {})
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
    @cell = args[:cell]
    @sector = args[:sector]

    assign_faction args[:faction]

    if args[:unpopulated] && args[:unpopulated] == true
      @population = 0.0
    elsif has_faction?
      @population = 100.0
    else
      @population = 10.0
    end

    @max_population = @size * 100

    image
    selection_image
    @image_image_ratio = @width.to_f/BASE_IMAGE_SIZE.to_f
    @selection_image_ratio = @image_image_ratio * 3
    selection_image_offset

    @selection_diameter = @width + 10
    @population_font = Gosu::Font.new($window, 'Courier', 15)
  end

  def update
    update_status
    update_population
  end

  def draw
    image.draw(@x, @y, 5, @image_image_ratio, @image_image_ratio)
    draw_selection_image
    draw_population

    remove_hovered_over
  end

  def within?(x, y)
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

  def hovered_over
    @hovered_over = true
  end

  def remove_hovered_over
    @hovered_over = false
  end

  def hovered_over?
    @hovered_over
  end

  def receive_population
    start_animation
  end

  def fleet_inbound_from(planet)
    start_animation if planet.human_faction?
  end

  def start_animation
    @animating_started_at = Time.now
  end

  def finish_animating
    @animating_started_at = nil
  end

  def animate_planet?
    @animating_started_at
  end

  def can_transfer_to?(other_planet)
    # Fix: make it able to transfer always to the closest possible planet
    # Can also transfer to anything less than a constant distance

    transferrable_distance = 250
    return false if other_planet == self
    return true if self.sector == other_planet.sector &&
        self.row == other_planet.row &&
        (self.cell - other_planet.cell).abs <= 1

    Gosu::distance(self.x_center, self.y_center, other_planet.x_center, other_planet.y_center) < transferrable_distance
  end

  def transferrable_planets
    $window.planets.select { |planet| can_transfer_to? planet }
  end

  private

  def image
    @image ||= Gosu::Image.new("media/planets/planet_#{rand(15) + 1}.png")
  end

  def selection_image
    @selection_image ||= Gosu::Image.new("media/selection.png")
  end

  def draw_selection_image
    if animate_planet?
      selection_image.draw(@x + selection_image_offset,
                           @y + selection_image_offset,
                           0,
                           @selection_image_ratio,
                           @selection_image_ratio,
                           faction_color
                           #$window.oscillating_color(Gosu::Color::YELLOW)
      )
    elsif hovered_over?
      selection_image.draw(@x + selection_image_offset,
                           @y + selection_image_offset,
                           0,
                           @selection_image_ratio,
                           @selection_image_ratio,
                           faction_color
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
    @population_font.draw("#{@population.to_i}", @x, @y, 7, 1, 1, faction_color)

    # draw triangles for 1/16ths of max population
    number_of_ticks = 32
    degree_step = 360/number_of_ticks
    radius = @size.to_f/2
    number_of_ticks.times do |i|
      Gosu.rotate(180 + degree_step/2 + i * degree_step, x_center, y_center) do
        $window.draw_triangle(x_center, y_center, $window.color_with_opactity(faction_color, 80),
                            x_center - 3, y_center + radius, $window.color_with_opactity(faction_color, 80),
                            x_center + 3, y_center + radius, $window.color_with_opactity(faction_color, 80),
                            1)
      end
      break if population < max_population * (i+1)/number_of_ticks
    end
  end

  def update_status
    if animate_planet?
      finish_animating if (Time.now - @animating_started_at > 0.5)
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