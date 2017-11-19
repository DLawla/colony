# frozen_string_literal: true

require 'gosu'
require 'chipmunk'
require 'byebug'

require './lib/planet_factory'
require './lib/selection_manager'

class GameWindow < Gosu::Window

  attr_accessor :entities, :delta, :planets

  def initialize
    super(450, 700, false)
    self.caption = 'Colony'

    # Play with Chipmunk
    @dt = (1.0/60.0)
    @space = CP::Space.new
    @body = CP::Body.new(1, 1)

    # Test body
    shape_array = [CP::Vec2.new(-25.0, -25.0), CP::Vec2.new(-25.0, 25.0), CP::Vec2.new(25.0, 1.0), CP::Vec2.new(25.0, -1.0)]
    @shape = CP::Shape::Poly.new(@body, shape_array, CP::Vec2.new(0,0))
    @shape.collision_type = :transfer_lane
    @space.add_body(@body)
    @space.add_shape(@shape)

    initialize_shape
    initialize_mouse_body

    #{@player = Player.new(shape)}
    @shape.body.p = CP::Vec2.new(200.0, 200.0) # position
    @shape.body.v = CP::Vec2.new(0.0, 0.0) # velocity

    # Keep in mind that down the screen is positive y, which means that PI/2 radians,
    # which you might consider the top in the traditional Trig unit circle sense is actually
    # the bottom; thus 3PI/2 is the top
    @shape.body.a = (3*Math::PI/2.0) # angle in radians; faces towards top of screen
    # @player.warp(CP::Vec2.new(320, 240))

    @test_image = Gosu::Image.new("media/selection.png")
    @mouse_image = Gosu::Image.new("media/selection.png")

    # Mouse body
    @mouse_body = CP::Body.new(1, 1)
    shape_array = [CP::Vec2.new(-5, -5.0), CP::Vec2.new(-5.0, 5.0), CP::Vec2.new(5.0, 5.0), CP::Vec2.new(5.0, -5.0)]
    @mouse_shape = CP::Shape::Poly.new(@mouse_body, shape_array, CP::Vec2.new(0,0))
    @mouse_shape.sensor = true
    @mouse_shape.collision_type = :mouse
    @space.add_body(@mouse_body)
    @space.add_shape(@mouse_shape)

    @space.add_collision_func(:transfer_lane, :mouse) do |transfer_lane, mouse|
      puts 'Mouse over!'
    end

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
    @mouse_shape.body.p = CP::Vec2.new(mouse_x, mouse_y)
    #puts @mouse_shape.bb_raw
    #@space.step(1)

    update_times

    @entities.each do |entity|
      entity.update
    end

    update_previous_button_downs

    @space.step(@dt)
  end

  # Called by Gosu
  def draw
    @test_image.draw_rot(@shape.body.p.x, @shape.body.p.y, 10, @shape.body.a.radians_to_gosu)

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
