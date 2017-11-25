# frozen_string_literal: true

require 'gosu'
require 'byebug'

require './lib/modules/has_state'
require './lib/planet_factory'
require './lib/selection_manager'
require './lib/ui_elements/button'
require './lib/opponents/v1'

class Colony < Gosu::Window
  include HasState

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

    # Images and fonts
    background_image
    @font = Gosu::Font.new(self, 'Courier', 40)

    # Time variables
    @elapsed_time = 0
    @delta = 0
    @last_time = 0

    @entities = []

    # Button one shots
    @lm_previous = false
    @space_previous = false

    starting_menu!
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

    if started?
      check_for_game_end
    end

    update_previous_button_downs
  end

  # Called by Gosu
  def draw
    background_image.draw(0, 0, 0)

    if starting_menu?
      @font.draw('Good day, human', 10, 10, 20)
    elsif started?
      @font.draw("#{@elapsed_time.to_i}", 10, 10, 20)
    end

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

  def fleets
    @entities.select { |e| e.is_a? Fleet }
  end

  def transfer_lanes
    @entities.select { |e| e.is_a? TransferLane }
  end

  def load_starting_menu
    $window.destroy_entities($window.entities)
    option1 = Button.new(100, 75, 'Start') do
      start_game!
    end
    option2 = Button.new(50, 225, 'AI Battle', width: 325) do
      start_ai_battle!
    end
    $window.add_entities [option1, option2]
  end

  def load_game_start
    $window.destroy_entities($window.entities)
    @background_image = random_background_image

    # Time variables
    @elapsed_time = 0
    @delta = 0
    @last_time = 0

    # Load entities
    PlanetFactory.new
    $window.add_entities([SelectionManager.new, Opponents::V1.new])
  end

  def load_ai_battle_start
    $window.destroy_entities($window.entities)
    @background_image = random_background_image

    # Time variables
    @elapsed_time = 0
    @delta = 0
    @last_time = 0

    # Load entities
    PlanetFactory.new
    $window.add_entities([SelectionManager.new, Opponents::V1.new, Opponents::V1.new(:friendly)])
  end

  def load_end_menu
    button = Button.new(80, 100, 'Restart', width: 260) do
      start_game!
    end
    $window.add_entities [button]
  end

  private

  def check_for_game_end
    return unless (all_planets = planets)
    end_game! if planets.select { |planet| planet.faction == planets.first.faction }.count == all_planets.count
  end

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
    @background_image ||= random_background_image
  end

  def random_background_image
    Gosu::Image.new("media/backgrounds/background_#{rand(5) + 1}.png")
  end

  def cursor
    @cursor ||= Gosu::Image.new('media/cursor.png')
  end
end

window = Colony.new
window.show
