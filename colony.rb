# frozen_string_literal: true

require 'gosu'
require 'byebug'

require './lib/planet_factory'
require './lib/selection_manager'

class Colony < Gosu::Window

  attr_accessor :entities
  attr_reader :debug, :delta, :elapsed_time

  COLOR_FRIENDLY = 0x70_00ff00
  COLOR_ENEMY = 0x70_ff0000
  COLOR_NEUTRAL = 0x70_ffff00
  COLOR_TRANSPARENT = 0x00_808080

  def initialize
    super(450, 700, false)
    self.caption = 'Colony'

    # Yes, it's a global. But it is a justifying use-case. Otherwise, would need to be passed
    # around to every class initialization, which means it is basically a global already. Therefor,
    # calling it as a global to simplify.
    $window = self

    @debug = true

    # Time variables
    @elapsed_time = 0
    @delta = 0
    @last_time = 0

    # Images and fonts
    background_image
    @font = Gosu::Font.new(self, 'Courier', 40)

    # Load entities
    @entities = []
    PlanetFactory.new
    add_entities([SelectionManager.new])

    # Button one shots
    @lm_previous = false
    @space_previous = false
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
      when Gosu::KB_SPACE
        button_down?(id) && !@space_previous
    else
      button_down?(id)
    end
  end

  def oscillating_color(base_color, oscillation_scale = 150)
    puts base_color.gl
    result = base_color.gl + Math::acos(@elapsed_time%1 ) * oscillation_scale
    result.to_i
  end

  def add_entities(entities_array)
    @entities += entities_array
  end

  def destroy_entities(entities_array)
    @entities -= entities_array
  end

  def planets
    @entities.select { |e| e.is_a? Planet }
  end

  def transfer_lanes
    @entities.select { |e| e.is_a? TransferLane }
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
    @space_previous = button_down? Gosu::KB_SPACE
  end

  def background_image
    @background_image ||= Gosu::Image.new("media/backgrounds/background_#{rand(5) + 1}.png")
  end

  def cursor
    @cursor ||= Gosu::Image.new('media/cursor.png')
  end
end

window = Colony.new
window.show
