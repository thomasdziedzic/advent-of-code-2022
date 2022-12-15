class Problem
  def initialize(input_filename)
    input_path = File.join(File.dirname(__FILE__), input_filename)
    @rock_paths = File.readlines(input_path, chomp: true).map do |line|
      line.split(' -> ').map { |point| point.split(',').map(&:to_i) }
    end
  end

  def answer_part_1
    cave = Cave.new(@rock_paths)
    cave.fill_with_sand(:part_one)
    cave.units_of_sand
  end

  def answer_part_2
    cave = Cave.new(@rock_paths)
    cave.fill_with_sand(:part_two)
    cave.units_of_sand
  end

  class Cave
    def initialize(rock_paths)
      @sorted_columns = {}
      @floor_y = 2

      rock_paths.each do |rock_path|
        rock_path.each_cons(2) do |start_point, end_point|
          # require 'debug'; debugger
          start_x, start_y = start_point
          end_x, end_y = end_point
          move_x = (end_x - start_x) / (end_x - start_x).abs rescue 0
          move_y = (end_y - start_y) / (end_y - start_y).abs rescue 0

          current_x = start_x
          current_y = start_y
          @floor_y = [current_y + 2, @floor_y].max

          loop do
            @sorted_columns[current_x] = SortedColumn.new if !@sorted_columns.has_key?(current_x)
            sorted_column = @sorted_columns[current_x]
            sorted_column.add(current_y, :rock)

            break if current_x == end_x && current_y == end_y

            current_x += move_x
            current_y += move_y
          end
        end
      end

      # puts @sorted_columns.inspect
    end

    def fill_with_sand(part)
      loop do
        # puts "dropping one sand"
        # puts 'filling one sand'
        break if drop_one_sand(500, 0, part).nil?
        # puts @sorted_columns.inspect
      end
    end

    def units_of_sand
      @sorted_columns.values.sum(&:sand)
    end

    private

    def drop_one_sand(x, y, part)
      # puts "dropping sand at #{x} #{y}"
      if part == :part_two
        @sorted_columns[x] ||= SortedColumn.new
      end

      sorted_column = @sorted_columns[x]

      if sorted_column.nil?
        # puts 'sorted_column is nil, returning'
        return nil
      end

      candidate_y = sorted_column.min_at_or_after(y)

      if part == :part_two
        candidate_y ||= @floor_y
      end
      # puts "candidate_y #{candidate_y}"
      if candidate_y.nil?
        # puts 'candidate_y is nil, returning'
        return nil
      end

      candidate_y -= 1

      if part == :part_two
        @sorted_columns[x - 1] ||= SortedColumn.new
        @sorted_columns[x + 1] ||= SortedColumn.new
      end

      left_column = @sorted_columns[x - 1]
      right_column = @sorted_columns[x + 1]

      if left_column.nil?
        # puts 'left_column nil, returning nil'
        return nil
      elsif left_column.empty_at?(candidate_y + 1, part == :part_two ? @floor_y : nil)
        # puts "dropping sand to the left at #{candidate_y + 1}"
        return drop_one_sand(x - 1, candidate_y + 1, part)
      elsif right_column.nil?
        # puts 'right_column nil, returning nil'
        return nil
      elsif right_column.empty_at?(candidate_y + 1, part == :part_two ? @floor_y : nil)
        # puts "dropping sand to the right at #{candidate_y + 1}"
        return drop_one_sand(x + 1, candidate_y + 1, part)
      else
        # puts "dropping sand at #{candidate_y}"
        sorted_column.add(candidate_y, :sand)
        if part == :part_two && x == 500 && candidate_y == 0
          return nil
        end
        return true
      end
    end
  end

  class SortedColumn
    attr_reader :sand

    def initialize
      @list = []
      @sand = 0
    end

    def min_at_or_after(element)
      @list.drop_while { |x| x < element }.first
    end

    def add(element, type)
      # add_sorted(element, type, 0, @list.length - 1)
      @list << element
      @list.uniq!
      @list.sort!
      @sand += 1 if type == :sand
    end

    def empty_at?(element, floor)
      return false if floor && floor == element
      @list.find_index { |x| x == element }.nil?
    end

    private

    def add_sorted(element, type, left_index, right_index)
      # puts "add_sorted #{element} #{type} #{left_index} #{right_index}"
      if left_index == right_index
        index = left_index
        focus = @list[left_index]
        return if focus == element

        if focus < element
          @list.insert(index + 1, element)
        else
          @list.insert(index, element)
        end

        @sand += 1 if type == :sand
      elsif left_index < right_index
        index = (right_index - left_index) / 2
        focus = @list[index]
        return if focus == element

        if focus < element
          new_left_index = index + 1
          new_right_index = right_index
        else
          new_left_index = left_index
          new_right_index = index - 1
        end

        add_sorted(element, type, new_left_index, new_right_index)
      else
        # empty array
        @list.insert(0, element)
        @sand += 1 if type == :sand
      end
    end
  end
end
