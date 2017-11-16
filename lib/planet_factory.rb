# frozen_string_literal: true

require './lib/planet'

class PlanetFactory
  def initialize(window)
    @window = window

    planets = build_planets

    @window.entities.push(planets).flatten!
    @window.planets.push(planets).flatten!
  end

  private

  def build_planets
    coordinates = generate_planet_coordinates
    coordinates.each_with_index.map do |coordinate, i|
      faction = if i.zero?
                  :enemy
                elsif i == coordinates.length - 1
                  :friendly
                end
      unpopulated = faction
      Planet.new(@window,
                 x: coordinate[:x],
                 y: coordinate[:y],
                 faction: faction,
                 random: !faction,
                 unpopulated: unpopulated?(faction))
    end
  end

  def unpopulated?(faction)
    !faction && rand(0..1)
  end

  def generate_planet_coordinates
    # an array of random length w/ a random number representing number of eveningly spaced cells per row
    row_count = rand(4..6)
    row_cell_map = row_count.times.map{ |i| rand(2..3)}

    coordinates = []
    row_height = @window.height/row_cell_map.length

    row_cell_map.each_with_index do |number_of_row_cells, i|
      cell_width = @window.width/number_of_row_cells

      number_of_row_cells.times do |j|
        coordinates << {x: (j * cell_width + cell_width/2), y: (i * row_height + row_height/2)}
      end
    end
    coordinates
  end
end
