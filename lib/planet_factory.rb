require './lib/planet'

class PlanetFactory
  def initialize(window)
    @window = window
    @window.entities.push(Planet.new(@window, 100, 50), Planet.new(@window, 100, 200))
  end
end
