# frozen_string_literal: true

require 'gosu'
require 'byebug'

require './lib/planet_factory'

# Phases
# [DONE] Two planets (drawn), rendered w/ mouse selection and image change when selected
# [DONE] Import planet sprites
# [DONE] Create random planet sizing, give planet a size trait, and adjust selection box accordingly
# [DONE] Create populations (increase by planet size, so hold a population and max population value) and ensure they max out out
# [DONE] When selected, support moving ALL planet's population to an adjacent selected planet
# [DONE] When a planet is selected, on mousing over a nearby planet

# [] Figure out a way to capture what an adjacent planet is, perhaps, for each planet, create an array of objects
#    for each adjacent planet which is the degrees (0 - 360) they are relative the current
# [] Update the selection method to not unselect when clicking empty space
# [] When a planet is selected and holding down the mouse, draw a line to the mouse of a maximum length, showing
#    a value of the current line length (0 - 100%)
# [] Get some trigger to fire when the mouse is released, and returns the length of the line
# [] Create a way for the population transfer line to 'stick' with an adjacent planet (ie, if pointing towards it or
#    +/- 10 degrees) it will stick on it.
# [] Population transfer line changes color depending on if it is lined up with another planet or not

# [] Battle system...

# [] Import music
#    Have two .ogg files, but this is awesome too: Miracle by Blackmill﻿ OR Know You Well (Feat. Laura Hahn) by Michael St﻿ Laurent
# [] Import music toggle

class GameWindow < Gosu::Window

  attr_accessor :entities, :delta, :planets

  def initialize
    super(288, 512, false)
    self.caption = 'Colony'

    # Time variables
    @elapsed_time = 0
    @delta = 0
    @last_time = 0

    # Images and fonts
    background_image
    @font = Gosu::Font.new(self, 'Courier', 40)

    @entities = []
    @planets = []

    # Load entities
    PlanetFactory.new(self)

    # Add entities
    @entities << []
    @entities.flatten!

    # Button one shots
    @lm_previous = false
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

    update_previous_button_downs
  end

  # Called by Gosu
  def draw
    background_image.draw(0, 0, 0)

    @font.draw("#{@elapsed_time.to_i}", 10, 10, 20)

    @entities.each do |entity|
      entity.draw
    end
  end

  def button_down_one_shot?(id)
    case id
    # Add more conditions as needed
      when Gosu::MsLeft
        button_down?(id) && !@lm_previous
    else
      button_down?(id)
    end
  end

  private

  def update_times
    current_time = Gosu::milliseconds / 1000.0
    @delta = [current_time - @last_time, 0.25].min
    @last_time = current_time

    @elapsed_time += @delta
  end

  def update_previous_button_downs
    @lm_previous = button_down? Gosu::MsLeft
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
