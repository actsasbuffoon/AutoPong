# Main

# Monkey patching between? so it can handle numbers coming in by reverse order.
class Fixnum
  
  def between?(first, second)
    super *[first, second].sort
  end
  
end

class Main < Processing::App

  def setup
    size 800, 600
    background 0
    no_stroke
    fill 255
    frame_rate 30
    
    @paddles = [
      Paddle.new(:x => 25, :y => 5, :width => 15, :height => 100, :max_speed => 10),
      Paddle.new(:x => 760, :y => 5, :width => 15, :height => 100, :max_speed => 10)
    ]
    
    @ball = Ball.new(:x => 400, :y => 300, :width => 25, :height => 25, :x_speed => 8, :y_speed => 0, :max_vert => 5)
  end
  
  def draw
    background 0
    @ball.update(width, height, @paddles)
    @paddles.each {|p| p.update(width, height, @ball)}    
  end
  
  class Ball
    
    attr_accessor :x, :y, :width, :height, :x_speed, :y_speed, :max_vert

    def initialize(args = {})
      args.each_pair {|k, v| send("#{k}=", v)}
    end

    def draw
      ellipse(@x, @y, @width, @height)
    end
    
    # Generates a new random vertical speed
    def vert
      rand(@max_vert * 2) - @max_vert
    end
    
    # Manipulate the speed and position of the ball in the event of colliding with an edge of the window
    def check_boundary_collision(w, h)
      if @y > h || @y < 0
        if @y < 0
          @y_speed = @max_vert
          @y = 1
        elsif @y > h
          @y_speed = -@max_vert
          @y = h - 1
        end
      
        @y_speed = @y_speed * -1
        @y_speed = vert
      end
      
      if @x > w || @x < 0
        @x_speed = @x_speed * -1
        @y_speed = vert
      end
    end
    
    def update(w, h, paddles)
      @x += @x_speed
      @y += @y_speed
      
      check_boundary_collision(w, h)
      
      paddles.each do |p|
        if @x.between?(p.x - 5, p.x + p.width + 5) && @y.between?(p.y - 5, p.y + p.height + 5)
          @x_speed = @x_speed * -1
          @y_speed = vert
          @x = p.x + p.width + 1 if @x < w / 2
          @x = p.x - 1 if @x > w / 2
        end
      end
      
      draw
    end
    
  end
  
  class Paddle

    attr_accessor :x, :y, :width, :height, :x_speed, :y_speed, :max_speed

    def initialize(args = {})
      args.each_pair {|k, v| send("#{k}=", v)}
    end

    def draw
      rect(@x, @y, @width, @height)
    end
    
    def update(w, h, ball)
      if ball.x.between? @x, w / 2
        if @y + @height / 2 > ball.y
          @y -= [@max_speed, ((@y + @height / 2) - ball.y).abs].min
        elsif @y + @height / 2 < ball.y
          @y += [@max_speed, (ball.y - (@y + @height / 2)).abs].min
        end
      end
      @y = 1 if @y < 1
      @y = h - @height - 1 if @y + @height >= h
      draw
    end
    
  end
  
end

Main.new :title => "AutoPong"