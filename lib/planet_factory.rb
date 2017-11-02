# frozen_string_literal: true

require './lib/planet'

class PlanetFactory
  def initialize(window)
    @window = window
    @window.entities.push(Planet.new(@window, x: 100, y: 50),
                          Planet.new(@window, x: 100, y: 200),
                          Planet.new(@window, x: 100, y: 350, random: true))
  end
end
