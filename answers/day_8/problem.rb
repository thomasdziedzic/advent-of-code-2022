class Problem
  def initialize
    input_path = File.join(File.dirname(__FILE__), 'input')
    @grid = File.readlines(input_path, chomp: true).map do |line|
      line.chars.map(&:to_i)
    end
  end

  def answer_part_1
    Grid.new(@grid).number_of_trees_visible_from_outside_the_grid
  end

  def answer_part_2
    Grid.new(@grid).max_scenic_score
  end

  class Grid
    def initialize(grid)
      @grid = grid.map do |row|
        row.map do |height|
          Tree.new(height)
        end
      end

      populate_max_height_left
      populate_max_height_right
      populate_max_height_up
      populate_max_height_down
      populate_viewing_distance_left
      populate_viewing_distance_right
      populate_viewing_distance_up
      populate_viewing_distance_down
    end

    def number_of_trees_visible_from_outside_the_grid
      @grid.flatten.filter(&:visible?).count
    end

    def max_scenic_score
      @grid.flatten.map(&:scenic_score).max
    end

    private

    def populate_max_height_left
      @grid.each do |row|
        max_height_left = -Float::INFINITY
        row.each do |tree|
          tree.max_height_left = max_height_left
          max_height_left = [max_height_left, tree.height].max
        end
      end
    end

    def populate_max_height_right
      grid_width = @grid.first.length

      @grid.each do |row|
        max_height_right = -Float::INFINITY
        (grid_width - 1).downto(0) do |row_index|
          tree = row[row_index]
          tree.max_height_right = max_height_right
          max_height_right = [max_height_right, tree.height].max
        end
      end
    end

    def populate_max_height_up
      grid_height = @grid.length
      grid_width = @grid.first.length

      (0...grid_width).each do |x|
        max_height_up = -Float::INFINITY
        (0...grid_height).each do |y|
          tree = @grid[y][x]
          tree.max_height_up = max_height_up
          max_height_up = [max_height_up, tree.height].max
        end
      end
    end

    def populate_max_height_down
      grid_height = @grid.length
      grid_width = @grid.first.length

      (0...grid_width).each do |x|
        max_height_down = -Float::INFINITY
        (grid_height - 1).downto(0) do |y|
          tree = @grid[y][x]
          tree.max_height_down = max_height_down
          max_height_down = [max_height_down, tree.height].max
        end
      end
    end

    def populate_viewing_distance_left
      common_populate_viewing_distance(@grid, :viewing_distance_left=)
    end

    def populate_viewing_distance_right
      grid = @grid.map do |row|
        row.reverse
      end

      common_populate_viewing_distance(grid, :viewing_distance_right=)
    end

    def populate_viewing_distance_up
      common_populate_viewing_distance(@grid.transpose, :viewing_distance_up=)
    end

    def populate_viewing_distance_down
      grid = @grid.transpose.map do |row|
        row.reverse
      end

      common_populate_viewing_distance(grid, :viewing_distance_down=)
    end

    def common_populate_viewing_distance(grid, viewing_distance_writer)
      grid_width = @grid.first.length

      grid.each do |row|
        grid_width.times do |x|
          tree = row[x]
          trees_to_the_left = row[0,x]
          agg = 0
          trees_to_the_left.reverse.each do |left_tree|
            agg += 1
            break if left_tree.height >= tree.height
          end
          tree.send(viewing_distance_writer, agg)
        end
      end
    end
  end

  class Tree
    attr_reader :height
    attr_writer :max_height_left, :max_height_right, :max_height_up, :max_height_down
    attr_writer :viewing_distance_left, :viewing_distance_right, :viewing_distance_up, :viewing_distance_down

    def initialize(height)
      @height = height
      @max_height_left = nil
      @max_height_right = nil
      @max_height_up = nil
      @max_height_down = nil
      @viewing_distance_left = nil
      @viewing_distance_right = nil
      @viewing_distance_up = nil
      @viewing_distance_down = nil
    end

    def visible?
      [@max_height_left, @max_height_right, @max_height_up, @max_height_down].min < @height
    end

    def scenic_score
      @viewing_distance_left * @viewing_distance_right * @viewing_distance_up * @viewing_distance_down
    end
  end
end
