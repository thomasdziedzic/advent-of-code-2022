class Problem
  class Pair
    def initialize(first_range, second_range)
      @first_range = first_range
      @second_range = second_range
    end

    def contains?
      Pair.range_contains_another_range?(@first_range, @second_range) || Pair.range_contains_another_range?(@second_range, @first_range)
    end

    def overlaps?
      @second_range.begin <= @first_range.end && @first_range.begin <= @second_range.end
    end

    def self.parse(line)
      first_raw, second_raw = line.split(',')
      first_range = parse_range(first_raw)
      second_range = parse_range(second_raw)
      Pair.new(first_range, second_range)
    end

    private

    def self.parse_range(input)
      beginning, ending = input.split('-')
      (beginning.to_i)..(ending.to_i)
    end

    def self.range_contains_another_range?(r1, r2)
      r1.begin <= r2.begin && r2.end <= r1.end
    end
  end

  def initialize
    @input_path = File.join(File.dirname(__FILE__), 'input')
  end

  def answer_part_1
    File.readlines(@input_path, chomp: true).map { |line| Pair.parse(line) }.filter(&:contains?).count
  end

  def answer_part_2
    File.readlines(@input_path, chomp: true).map { |line| Pair.parse(line) }.filter(&:overlaps?).count
  end
end
