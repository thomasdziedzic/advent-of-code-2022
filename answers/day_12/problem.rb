require_relative '../../lib/min_priority_queue'

class Problem
  def initialize(input_filename)
    input_path = File.join(File.dirname(__FILE__), input_filename)
    @grid = Grid.new(input_path)
  end

  def answer_part_1
    @grid.fewest_steps_to_get_best_signal
  end

  def answer_part_2
    @grid.fewest_steps_to_get_best_signal_from_any_a
  end

  class Square
    attr_reader :char, :position
    attr_accessor :dist, :prev

    def initialize(char, x, y)
      @char = char
      @dist = Float::INFINITY
      @prev = nil
      @position = Position.new(x, y)
    end

    def can_move_to?(other_square)
      return false if other_square.nil?
      (other_square.get_effective_char.ord - self.get_effective_char.ord) <= 1
    end

    def get_effective_char
      case @char
      when 'S'
        effective_char = 'a'
      when 'E'
        effective_char = 'z'
      else
        effective_char = @char
      end

      effective_char
    end

    def neighbor_positions
      [
        Position.new(@position.x, @position.y - 1),
        Position.new(@position.x, @position.y + 1),
        Position.new(@position.x - 1, @position.y),
        Position.new(@position.x + 1, @position.y),
      ]
    end

    def reset_data
      @dist = Float::INFINITY
      @prev = nil
    end
  end

  Position = Struct.new(:x, :y)

  class Grid
    def initialize(input_path)
      @grid = File.readlines(input_path, chomp: true).map.with_index do |line, y|
        line.chars.map.with_index { |char, x| Square.new(char, x, y) }
      end
      @start_position = find_position('S')
      @end_position = find_position('E')
    end

    def fewest_steps_to_get_best_signal
      get_square_at_position(@start_position).dist = 0

      q = MinPriorityQueue.new

      @grid.flatten.each do |square|
        q.add_with_priority(square, square.dist)
      end

      while (u = q.extract_min)
        u.neighbor_positions.each do |neighbor_position|
          neighbor_square = get_square_at_position(neighbor_position)
          next if !u.can_move_to?(neighbor_square)
          alt = u.dist + 1
          if alt < neighbor_square.dist
            neighbor_square.dist = alt
            neighbor_square.prev = u
            q.decrease_priority(neighbor_square, alt)
          end
        end
      end

      get_square_at_position(@end_position).dist
    end

    def fewest_steps_to_get_best_signal_from_any_a
      steps = []

      steps << fewest_steps_to_get_best_signal

      @grid.flatten.each do |square|
        next if square.char != 'a'
        reset_with_new_start_position(square.position)
        steps << fewest_steps_to_get_best_signal
      end

      steps.min
    end

    private

    def find_position(char)
      flattened_index = @grid.flatten.find_index { |square| square.char == char }
      y, x = flattened_index.divmod(@grid.first.length)
      Position.new(x, y)
    end

    def get_square_at_position(position)
      return nil if position.x < 0 || position.x >= @grid.first.length || position.y < 0 || position.y >= @grid.length

      @grid[position.y][position.x]
    end

    def reset_with_new_start_position(position)
      @start_position = position
      @grid.flatten.each { |square| square.reset_data }
    end
  end
end
