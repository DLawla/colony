# frozen_string_literal: true

require './lib/planet'

class PlanetFactory
  def initialize(window)
    @window = window

    planets = build_planets

    @window.add_entities(planets)
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
      Planet.new(@window,
                 x_center: coordinate[:x],
                 y_center: coordinate[:y],
                 row: coordinate[:row],
                 faction: faction,
                 random: !faction,
                 unpopulated: unpopulated?(faction))
    end
  end

  def unpopulated?(faction)
    !faction && rand(0..1)
  end

  def generate_planet_coordinates
    # planet location is determined by a random number of rows, each with a random number of columns, called 'cells'

    row_count = rand(4..6)
    row_cell_map = row_count.times.map{ |i| rand(2..3)}

    coordinates = []
    cell_height = @window.height/row_cell_map.length

    row_cell_map.each_with_index do |number_of_row_cells, i|
      cell_width = @window.width/number_of_row_cells

      number_of_row_cells.times do |j|
        # random location in cell bounded by the cell height/width and the max planet size

        x_center = j * cell_width + cell_width/2
        x_cell_buffer = cell_width - Planet::MAX_PLANET_SIZE
        x_randomness = rand(- x_cell_buffer/2..x_cell_buffer/2 )

        y_center = i * cell_height + cell_height/2
        y_cell_buffer = cell_height - Planet::MAX_PLANET_SIZE
        y_randomness = rand(- y_cell_buffer/2..y_cell_buffer/2 )

        coordinates << {x: (x_center + x_randomness), y: (y_center + y_randomness), row: i}
      end
    end
    coordinates
  end
end
