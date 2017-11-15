# frozen_string_literal: true

require './lib/helpers/circle'
require './lib/modules/has_faction'
include Math

class Planet
  include HasFaction

  attr_accessor :x, :y, :selected, :population, :faction
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

    unless args[:unpopulated]
      @population = 10.0
    else
      @population = 0.0
    end

    assign_faction args[:faction]

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

    draw_population
  end

  def update
    update_selection
    update_status
    update_population
  end

  def within_planet?(x, y)
    x.between?(@x, @x + @width) && y.between?(@y, @y + @width)
  end

  def select
    @window.planets.each(&:unselect)
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

  def selection_image_offset
    @selection_image_offset ||= ((BASE_IMAGE_SIZE * @image_image_ratio) -
                                (BASE_SELECTION_SIZE * @selection_image_ratio)) * 0.5
  end

  def update_selection
    if @window.button_down_one_shot? Gosu::MsLeft
      if @selected && (other_planet = other_planet_being_selected) && can_transfer_to?(other_planet)
        puts 'unselect and transfer'
        transfer_population_to(other_planet)
        unselect
      elsif friendly? && within_planet?(@window.mouse_x, @window.mouse_y)
        puts 'select'
        select
      else
        puts 'unselect'
        unselect
      end
    end
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

  def other_planet_being_selected
    @window.planets.reject { |planet| planet == self}.each do |planet|
      return planet if planet.within_planet?(@window.mouse_x, @window.mouse_y)
    end
    nil
  end

  def transfer_population_to(other_planet)
    remaining_population = 10
    if @population > remaining_population
      tranferring_population = @population - remaining_population
      transfer_to_friendly other_planet, tranferring_population, remaining_population if other_planet.friendly?
      transfer_to_non_friendly other_planet, tranferring_population, remaining_population if !other_planet.friendly?
    end
    other_planet.receive_population
  end

  def can_transfer_to?(other_planet)
    true
  end

  def transfer_to_friendly(other_planet, tranferring_population, remaining_population)
    other_planet.population += tranferring_population
    @population = remaining_population
  end

  def transfer_to_non_friendly(other_planet, tranferring_population, remaining_population)
    if other_planet.population > tranferring_population
      other_planet.population -= tranferring_population
    elsif other_planet.population == tranferring_population
      other_planet.population = 1
    else
      other_planet.population = tranferring_population - other_planet.population
      other_planet.make_friendly
    end
    @population = remaining_population
  end
end