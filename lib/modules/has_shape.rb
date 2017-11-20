module HasShape
  def self.included(base)
  end

  module ClassMethods#
  end

  def debug_draw_shape(shape)
    Gosu.rotate((shape.body.a * 180/Math::PI), shape.body.pos.x, shape.body.pos.y) do
      @window.draw_quad(shape.body.pos.x + shape.vert(0).x, shape.body.pos.y + shape.vert(0).y, random_debug_color,
                        shape.body.pos.x + shape.vert(1).x, shape.body.pos.y + shape.vert(1).y, random_debug_color,
                        shape.body.pos.x + shape.vert(2).x, shape.body.pos.y + shape.vert(2).y, random_debug_color,
                        shape.body.pos.x + shape.vert(3).x, shape.body.pos.y + shape.vert(3).y, random_debug_color,
                        1)
    end
  end

  private

  def random_debug_color
    @random_debug_color ||= 0x70_00ff00 - rand(0..200)
  end
end