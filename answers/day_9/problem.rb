class Problem
  def initialize
    input_path = File.join(File.dirname(__FILE__), 'input')
    @moves = File.readlines(input_path, chomp: true).map do |line|
      direction, steps = line.split
      Move.new(direction, steps.to_i)
    end
  end

  def answer_part_1
    rope = Rope.new(2)
    @moves.each do |move|
      rope.perform_move(move)
    end
    rope.number_of_unique_visited_positions_by_tail
  end

  def answer_part_2
    rope = Rope.new(10)
    @moves.each do |move|
      rope.perform_move(move)
    end
    rope.number_of_unique_visited_positions_by_tail
  end

  Move = Struct.new(:direction, :steps)

  class Knot
    attr_reader :x, :y

    def initialize
      @x = 0
      @y = 0
    end

    def to_a
      [@x, @y]
    end

    def move_closer_to(other_knot)
      return if touching?(other_knot)

      apply_x_diff = 0
      apply_y_diff = 0

      x_diff = other_knot.x - @x
      y_diff = other_knot.y - @y

      if x_diff == 0
        # same column
        apply_y_diff = y_diff < 0 ? -1 : 1
      elsif y_diff == 0
        # same row
        apply_x_diff = x_diff < 0 ? -1 : 1
      else
        apply_y_diff = y_diff < 0 ? -1 : 1
        apply_x_diff = x_diff < 0 ? -1 : 1
      end

      @x += apply_x_diff
      @y += apply_y_diff
    end

    def move_a_step_in_direction(direction)
      x_diff = 0
      y_diff = 0

      case direction
      when 'U'
        y_diff = 1
      when 'D'
        y_diff = -1
      when 'L'
        x_diff = -1
      when 'R'
        x_diff = 1
      else
        raise "Unknown direction: #{move.direction.inspect}"
      end

      @x += x_diff
      @y += y_diff
    end

    private

    def touching?(other_knot)
      (other_knot.x - @x).abs <= 1 && (other_knot.y - @y).abs <= 1
    end
  end

  class Rope
    def initialize(number_of_knots)
      @knots = Array.new(number_of_knots) { Knot.new }
      @tail_trace = [@knots.last.to_a]
    end

    def perform_move(move)
      move.steps.times do
        @knots.first.move_a_step_in_direction(move.direction)

        @knots.each_cons(2) do |head, tail|
          tail.move_closer_to(head)
        end

        @tail_trace << @knots.last.to_a
      end
    end

    def number_of_unique_visited_positions_by_tail
      @tail_trace.to_set.size
    end
  end
end
