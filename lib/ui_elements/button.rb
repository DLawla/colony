# frozen_string_literal: true

require './lib/fleet'

class Button
  attr_accessor :x, :y, :text

  def initialize x, y, text, args = {}, &block
    @x, @y, @text = x, y, text
    @post_click_block = block

    @width = args[:width] ||= 200
    @height = args[:height] ||= 100
    @font = Gosu::Font.new($window, 'Courier', 40)
  end

  def update
    if $window.button_down_one_shot? Gosu::MsLeft
      @post_click_block.call if mouse_within?
    end
  end

  def draw
    $window.draw_quad(@x, @y, Gosu::Color::BLACK,
                      @x + @width, @y, Gosu::Color::BLACK,
                      @x + @width, @y + @height, Gosu::Color::BLACK,
                      @x, @y + @height, Gosu::Color::BLACK,
                      1)
    @font.draw(@text, @x + @width/4, @y + @height/4, 20)
  end

  private

  def mouse_within?
    $window.mouse_x.between?(@x, @x + @width) && $window.mouse_y.between?(@y, @y + @height)
  end
end