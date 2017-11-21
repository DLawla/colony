# frozen_string_literal: true

require 'gosu'
require 'chipmunk'
require 'byebug'

require './lib/planet_factory'
require './lib/selection_manager'

class GameWindow < Gosu::Window

  attr_accessor :debug, :entities, :delta, :space, :mouse

  def initialize
    super(450, 700, false)
    self.caption = 'Colony'

    @debug = true

    # Chimpmunk setup
    @dt = (1.0/60.0)
    @space = CP::Space.new
    @body = CP::Body.new(1, 1)

    # Mouse body
    initialize_mouse_body

    # Time variables
    @elapsed_time = 0
    @delta = 0
    @last_time = 0

    # Images and fonts
    background_image
    @font = Gosu::Font.new(self, 'Courier', 40)

    # Load entities
    @entities = []
    PlanetFactory.new(self)
    add_entities([SelectionManager.new(self)])

    # Button one shots
    @lm_previous = false
  end

  def needs_cursor?
    true
  end

  # Called by Gosu
  def update
    update_mouse
    update_times

    @entities.each do |entity|
      entity.update
    end

    update_previous_button_downs

    @space.step(@dt)
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

  def oscillating_color(base_color, oscillation_scale = 150)
    result = base_color.gl + Math::acos(@elapsed_time%1 ) * oscillation_scale
    result.to_i
  end

  def add_entities(entities_array)
    @entities += entities_array
  end

  def destroy_entities(entities_array)
    entities_array.each { |entity| entity.teardown }
    @entities -= entities_array
  end

  def remove_body_and_shape(shape)
    @space.remove_body(shape.body)
    @space.remove_shape(shape)
  end

  def planets
    @entities.select { |e| e.is_a? Planet }
  end

  def transfer_lanes
    @entities.select { |e| e.is_a? TransferLane }
  end

  private

  def initialize_mouse_body
    body = CP::Body.new(1, 1)
    shape_array = [CP::Vec2.new(-5, -5.0), CP::Vec2.new(-5.0, 5.0), CP::Vec2.new(5.0, 5.0), CP::Vec2.new(5.0, -5.0)]
    @mouse = CP::Shape::Poly.new(body, shape_array, CP::Vec2.new(0,0))
    @mouse.sensor = true
    @mouse.collision_type = :mouse
    @space.add_body(body)
    @space.add_shape(@mouse)

    @space.add_collision_func(:transfer_lane, :mouse) do |transfer_lane, mouse|
      transfer_lane.object.mouse_over
    end

    @space.add_collision_func(:transfer_lane, :mouse) do |transfer_lane, mouse|
      transfer_lane.object.mouse_over
    end
  end

  def update_times
    current_time = Gosu::milliseconds / 1000.0
    @delta = [current_time - @last_time, 0.25].min
    @last_time = current_time

    @elapsed_time += @delta
  end

  def update_mouse
    @mouse.body.p = CP::Vec2.new(mouse_x, mouse_y)
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
