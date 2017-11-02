# frozen_string_literal: true

require 'gosu'
require 'byebug'

require './lib/planet_factory'

# Phases
# [DONE] Two planets (drawn), rendered w/ mouse selection and image change when selected
# [DONE] Import planet sprites
# [DONE] Create random planet sizing, give planet a size trait, and adjust selection box accordingly

# [] Create populations (increase by planet size, so hold a population and max population value) and ensure they max out out
  # Bonus points, population growth slows approching max

# [] Add in a debug mode to draw hitboxes
# [] Import music :)
# Have two .ogg files, but this is awesome too: Miracle by Blackmill﻿ OR Know You Well (Feat. Laura Hahn) by Michael St﻿ Laurent
# [] Import music toggle

# [] When selected, support moving ALL planet's population to an adjacent selected planet
# [] Battle system...


class GameWindow < Gosu::Window

  attr_accessor :entities, :delta

  def initialize
    super(288, 512, false)
    self.caption = 'Colony'

    # Time variables
    @elapsed_time = 0
    @delta = 0
    @last_time = 0

    # Images and fonts
    #cursor
    background_image
    @font = Gosu::Font.new(self, 'Courier', 40)

    @entities = []

    # Load entities
    PlanetFactory.new(self)

    # Add entities
    @entities << []
    @entities.flatten!
  end

  def needs_cursor?
    true
  end

  # Called by Gosu
  def update
    update_times

    @entities.each do |entity|
      entity.update
    end
  end

  # Called by Gosu
  def draw
    background_image.draw(0, 0, 0)
    #cursor.draw self.mouse_x, self.mouse_y, 10

    # draw the time
    @font.draw("#{@elapsed_time.to_i}", 10, 10, 20)

    @entities.each do |entity|
      entity.draw
    end
  end

  private

  def update_times
    current_time = Gosu::milliseconds / 1000.0
    @delta = [current_time - @last_time, 0.25].min
    @last_time = current_time

    @elapsed_time += @delta
  end

  def background_image
    @background_image ||= Gosu::Image.new("media/backgrounds/background_#{rand(5) + 1}.png")
  end

  def cursor
    @cursor ||= Gosu::Image.new('media/cursor.png')
  end
end

window = GameWindow.new
window.show
