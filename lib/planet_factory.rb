# frozen_string_literal: true

require './lib/planet'

class PlanetFactory
  def initialize
    planets = build_planets
    $window.add_entities(planets)
  end

  private

  def build_planets
    coordinates = generate_planet_coordinates($window.contenders.count > 2)
    current_faction_to_assign = 0

    coordinates.each_with_index.map do |coordinate, i|
      # assign to faction when this is cell 0 in row 0, or if first in last row of sector
      last_row_of_this_sector = coordinates.select{ |c| c[:sector] == coordinate[:sector] }.map{ |c| c[:row] }.max

      faction = if (coordinate[:row] == 0 && coordinate[:cell] == 0) ||
          coordinate[:row] == last_row_of_this_sector && coordinate[:cell] == 0
                  new_faction = $window.contenders[current_faction_to_assign].faction
                  current_faction_to_assign += 1
                  new_faction
                end

      Planet.new(x_center: coordinate[:x],
                 y_center: coordinate[:y],
                 row: coordinate[:row],
                 cell: coordinate[:cell],
                 faction: faction,
                 random: faction.nil?)

    end
  end

  def generate_planet_coordinates(high_density = false)
    return high_density_coordinates if high_density
    low_density_coordinates(0, 0, $window.width, $window.height)
  end

  def low_density_coordinates(x_1, y_1, x_2, y_2, sector = 0)
    # create coordinates randomly within the box formed by the two provide points. Assume the first point is the
    # top left of the box, the second is the bottom right

    # planet location is determined by a random number of rows, each with a random number of columns, called 'cells'
    row_count = rand(4..6)
    row_cell_map = row_count.times.map{ |i| rand(2..3)}

    coordinates = []
    cell_height = (y_2 - y_1)/row_cell_map.length

    row_cell_map.each_with_index do |number_of_row_cells, i|
      cell_width = (x_2 - x_1)/number_of_row_cells

      number_of_row_cells.times do |j|
        # random location in cell bounded by the cell height/width and the max planet size

        x_center = j * cell_width + cell_width/2
        x_cell_buffer = cell_width - Planet::MAX_PLANET_SIZE
        x_randomness = rand(- x_cell_buffer/2..x_cell_buffer/2 )

        y_center = i * cell_height + cell_height/2
        y_cell_buffer = cell_height - Planet::MAX_PLANET_SIZE
        y_randomness = rand(- y_cell_buffer/2..y_cell_buffer/2 )

        coordinates << {x: (x_1 + x_center + x_randomness),
                        y: (y_1 + y_center + y_randomness),
                        row: i, cell: j, sector: sector}
      end
    end
    coordinates

    # [{x: (100), y: (100), row: 0},
    # {x: (200), y: (100), row: 0},
    # {x: (100), y: (200), row: 1},
    # {x: (300), y: (100), row: 0}]
  end

  def high_density_coordinates
    low_density_coordinates(0, 0, $window.width/2, $window.height, 0) +
        low_density_coordinates($window.width/2, 0, $window.width, $window.height, 1)


    # [{x: (100), y: (100), row: 0},
    # {x: (200), y: (100), row: 0},
    # {x: (100), y: (200), row: 1},
    # {x: (300), y: (100), row: 0}]
  end
end
