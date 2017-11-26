# frozen_string_literal: true

require './lib/fleet'

class Button
  attr_accessor :x, :y, :z, :text, :image, :opacity

  def initialize x, y, text, args = {}, &block
    @x, @y, @text = x, y, text
    @post_click_block = block

    @width = args[:width] ||= 200
    @height = args[:height] ||= 100
    @z = args[:z] ||= 1
    @image = args[:image]
    @font = Gosu::Font.new($window, 'Courier', 40)
    @opacity = args[:opacity] || 200
  end

  def update
    if $window.button_down_one_shot? Gosu::MsLeft
      @post_click_block.call(self) if mouse_within?
    end
  end

  def draw
    if @image
      @image.draw(@x, @y, @z)
    end
    @font.draw(@text, @x + @width/4, @y + @height/4, @z + 1)
    $window.draw_quad(@x, @y, $window.color_with_opactity(Gosu::Color::BLACK, opacity),
                      @x + @width, @y, $window.color_with_opactity(Gosu::Color::BLACK, opacity),
                      @x + @width, @y + @height, $window.color_with_opactity(Gosu::Color::BLACK, opacity),
                      @x, @y + @height, $window.color_with_opactity(Gosu::Color::BLACK, opacity),
                      @z)
  end

  private

  def mouse_within?
    $window.mouse_x.between?(@x, @x + @width) && $window.mouse_y.between?(@y, @y + @height)
  end
end