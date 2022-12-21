class Problem
  def initialize(input_filename, options)
    input_path = File.join(File.dirname(__FILE__), input_filename)
    @gases = File.read(input_path).chomp.chars
    @options = options
  end

  def answer_part_1
    falling_rocks = FallingRocks.new(@gases)
    2022.times do
      falling_rocks.drop_rock
    end
    falling_rocks.highest_rock + 1 # add 1 since highest_rock is 0 indexed
  end

  def answer_part_2
    # falling_rocks = FallingRocks.new(@gases)
    # puts Time.current
    # 1_000_000_000_000.times do |i|
    #   puts Time.current if i % 1_000_000_000 == 0
    #   falling_rocks.drop_rock
    # end
    # falling_rocks.highest_rock + 1 # add 1 since highest_rock is 0 indexed
  end

  class FallingRocks
    attr_reader :highest_rock

    def initialize(gases)
      @chamber = []
      @highest_rock = -1
      @rocks = [
        HorizontalRock.new,
        CrossRock.new,
        ReversedLRock.new,
        VerticalRock.new,
        SquareRock.new,
      ]
      @next_rock = 0
      @num_rocks = @rocks.length
      @gases = gases
      @next_gas = 0
      @num_gases = @gases.length
    end

    def drop_rock
      rock = @rocks[@next_rock]
      rock.set_position(Position.new(2, @highest_rock + 4))

      while true
        gas = @gases[@next_gas]
        case gas
        when '<' # move left
          rock.move_left
          rock.move_right if violation?(rock)
        when '>' # move right
          rock.move_right
          rock.move_left if violation?(rock)
        else
          raise "unknown gas #{gas}"
        end
        @next_gas = (@next_gas + 1) % @num_gases

        rock.move_down
        if violation?(rock)
          rock.move_up
          settle(rock)
          @highest_rock = [@highest_rock, rock.topmost_y].max
          break
        end
      end

      @next_rock = (@next_rock + 1) % @num_rocks
    end

    private

    def violation?(rock)
      rock.leftmost_x < 0 || rock.rightmost_x > 6 || rock.bottommost_y < 0 || rock.segments.any? { |segment| @chamber.dig(segment.y, segment.x) == '#' }
    end

    def settle(rock)
      rock.segments.each do |segment|
        @chamber[segment.y] ||= ['.'] * 7
        @chamber[segment.y][segment.x] = '#'
      end
    end
  end

  Position = Struct.new(:x, :y)

  class Rock
    attr_reader :segments

    def set_position(new_position)
      diff_x = new_position.x - @position.x
      diff_y = new_position.y - @position.y

      @position.x += diff_x
      @position.y += diff_y

      @segments.each do |segment|
        segment.x += diff_x
        segment.y += diff_y
      end
    end

    def move_left
      @position.x -= 1
      @segments.each { |segment| segment.x -= 1 }
    end

    def move_right
      @position.x += 1
      @segments.each { |segment| segment.x += 1 }
    end

    def move_down
      @position.y -= 1
      @segments.each { |segment| segment.y -= 1 }
    end

    def move_up
      @position.y += 1
      @segments.each { |segment| segment.y += 1 }
    end
  end

  class HorizontalRock < Rock
    def initialize
      @position = Position.new(0, 0)
      @segments = [
        Position.new(@position.x, @position.y),
        Position.new(@position.x + 1, @position.y),
        Position.new(@position.x + 2, @position.y),
        Position.new(@position.x + 3, @position.y),
      ]
    end

    def leftmost_x
      @segments[0].x
    end

    def rightmost_x
      @segments[3].x
    end

    def bottommost_y
      @segments[0].y
    end

    def topmost_y
      @segments[0].y
    end
  end

  class CrossRock < Rock
    def initialize
      @position = Position.new(0, 0)
      @segments = [
        Position.new(@position.x + 1, @position.y),
        Position.new(@position.x, @position.y + 1),
        Position.new(@position.x + 1, @position.y + 1),
        Position.new(@position.x + 2, @position.y + 1),
        Position.new(@position.x + 1, @position.y + 2),
      ]
    end

    def leftmost_x
      @segments[1].x
    end

    def rightmost_x
      @segments[3].x
    end

    def bottommost_y
      @segments[0].y
    end

    def topmost_y
      @segments[4].y
    end
  end

  class ReversedLRock < Rock
    def initialize
      @position = Position.new(0, 0)
      @segments = [
        Position.new(@position.x, @position.y),
        Position.new(@position.x + 1, @position.y),
        Position.new(@position.x + 2, @position.y),
        Position.new(@position.x + 2, @position.y + 1),
        Position.new(@position.x + 2, @position.y + 2),
      ]
    end

    def leftmost_x
      @segments[0].x
    end

    def rightmost_x
      @segments[2].x
    end

    def bottommost_y
      @segments[0].y
    end

    def topmost_y
      @segments[4].y
    end
  end

  class VerticalRock < Rock
    def initialize
      @position = Position.new(0, 0)
      @segments = [
        Position.new(@position.x, @position.y),
        Position.new(@position.x, @position.y + 1),
        Position.new(@position.x, @position.y + 2),
        Position.new(@position.x, @position.y + 3),
      ]
    end

    def leftmost_x
      @segments[0].x
    end

    def rightmost_x
      @segments[0].x
    end

    def bottommost_y
      @segments[0].y
    end

    def topmost_y
      @segments[3].y
    end
  end

  class SquareRock < Rock
    def initialize
      @position = Position.new(0, 0)
      @segments = [
        Position.new(@position.x, @position.y),
        Position.new(@position.x + 1, @position.y),
        Position.new(@position.x, @position.y + 1),
        Position.new(@position.x + 1, @position.y + 1),
      ]
    end

    def leftmost_x
      @segments[0].x
    end

    def rightmost_x
      @segments[1].x
    end

    def bottommost_y
      @segments[0].y
    end

    def topmost_y
      @segments[2].y
    end
  end
end
