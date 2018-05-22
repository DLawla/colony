# frozen_string_literal: true

require 'gosu'
require 'byebug'

require './lib/modules/has_music'
require './lib/modules/has_state'
require './lib/planet_factory'
require './lib/selection_manager'
require './lib/ui_elements/button'
require './lib/contenders/human'
require './lib/contenders/v1'

class Colony < Gosu::Window
  include HasMusic
  include HasState

  attr_accessor :entities, :menu_controls
  attr_reader :debug, :delta, :elapsed_time, :height, :width

  COLOR_FRIENDLY = 0x70_00ff00
  COLOR_ENEMY = 0x70_ff0000
  COLOR_NEUTRAL = 0x70_ffff00
  COLOR_TRANSPARENT = 0x00_808080
  HUMAN_FACTION = 0

  def initialize
    @height = 700
    @width = 700#450
    super(@width, @height, false)
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
    @menu_controls = []

    # Button one shots
    @lm_previous = false
    @space_previous = false

    # Music
    load_music

    starting_menu!
  end

  def needs_cursor?
    true
  end

  # Called by Gosu
  def update
    @entities.each do |entity|
      entity.update
    end

    @menu_controls.each do |control|
      control.update
    end

    if started?
      check_for_game_end
      update_times
    end

    loop_through_songs
    update_previous_button_downs
  end

  # Called by Gosu
  def draw
    background_image.draw(0, 0, 0)

    if starting_menu?
      @font.draw('Good day, human', 10, 10, 20)
    elsif started? || game_ended?
      @font.draw("#{@elapsed_time.to_i}", 10, @height - 30, 2, 0.5, 0.5)
    end

    if game_ended?
      if planets.any? && planets.first.human_faction?
        @font.draw('Good work, human', 10, 10, 20)
      else
        @font.draw('Good work, fellow', 10, 10, 20)
        @font.draw('non-human.', 10, 40, 20)
      end
    end

    @entities.each do |entity|
      entity.draw
    end

    @menu_controls.each do |control|
      control.draw
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

  def color_with_opactity(color, opacity)
    opacity.clamp(1, 255)
    color = color.dup
    color.send(:alpha=, opacity)
    color
  end

  def add_entities(entities_array)
    @entities += entities_array
  end

  def destroy_entities(entities_array)
    @entities -= entities_array
  end

  def add_menu_controls(controls_array)
    @menu_controls += controls_array
  end

  def destroy_menu_controls(controls_array)
    @menu_controls -= controls_array
  end

  def planets
    @entities.select { |e| e.is_a? Planet }
  end

  def fleets
    @entities.select { |e| e.is_a? Fleet }
  end

  def contenders
    @entities.select { |e| e.class < BaseContender }
  end

  def transfer_lanes
    @entities.select { |e| e.is_a? TransferLane }
  end

  def load_starting_menu
    $window.destroy_entities($window.entities)
    option1 = Button.new(50, 75, 'Start') do
      start_game!
      $window.play_music
    end

    option2 = Button.new(50, 225, 'AI Battle', width: 325) do
      start_ai_battle!
    end

    option3 = Button.new(50, 375, 'Large AI Battle', width: 450) do
      start_large_ai_battle!
    end

    $window.add_entities [option1, option2, option3]
  end

  def load_game_start
    $window.destroy_entities($window.entities)
    @background_image = random_background_image

    # Time variables
    @elapsed_time = 0
    @delta = 0
    @last_time = 0

    # Load entities
    $window.add_entities([SelectionManager.new,
                          Opponents::V1.new(faction: 1),
                          Opponents::Human.new(faction: HUMAN_FACTION)])
    PlanetFactory.new
  end

  def load_ai_battle_start
    $window.destroy_entities($window.entities)
    @background_image = random_background_image

    # Time variables
    @elapsed_time = 0
    @delta = 0
    @last_time = 0

    # Load entities
    $window.add_entities([SelectionManager.new,
                          Opponents::V1.new(faction: 1),
                          Opponents::V1.new(faction: 2)])
    PlanetFactory.new
  end

  def load_large_ai_battle_start
    $window.destroy_entities($window.entities)
    @background_image = random_background_image

    # Time variables
    @elapsed_time = 0
    @delta = 0
    @last_time = 0

    # Load entities
    $window.add_entities([SelectionManager.new,
                          Opponents::V1.new(faction: 1),
                          Opponents::V1.new(faction: 2),
                          Opponents::V1.new(faction: 3),
                          Opponents::V1.new(faction: 4)])
    PlanetFactory.new
  end

  def load_end_menu
    button = Button.new(80, 200, 'Menu', width: 260) do
      starting_menu!
    end
    $window.add_entities [button]
  end

  private

  def check_for_game_end
    return unless (all_planets = planets)
    end_game! if planets.select { |planet| planet.faction == planets.first.faction }.count == all_planets.count
    end_game! if planets.select { |planet| planet.faction.nil? }.count == all_planets.count
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
