# frozen_string_literal: true

require './lib/planet'

class PlanetFactory
  def initialize(window)
    @window = window
    planets = Planet.new(@window, x: 100, y: 50, faction: :enemy),
              Planet.new(@window, x: 100, y: 200, random: true, unpopulated: true),
              Planet.new(@window, x: 100, y: 350, faction: :friendly)
    @window.entities.push(planets).flatten!
    @window.planets.push(planets).flatten!
  end
end
