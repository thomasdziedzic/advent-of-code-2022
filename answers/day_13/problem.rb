require 'json'

class Problem
  def initialize(input_filename)
    @input_path = File.join(File.dirname(__FILE__), input_filename)
  end

  def answer_part_1
    pairs = File.readlines(@input_path, chomp: true).split('').map do |left, right|
      [JSON.load(left), JSON.load(right)]
    end

    pairs.filter_map.with_index do |(left, right), index|
      index + 1 if Problem.in_right_order?(left, right)
    end.sum
  end

  def answer_part_2
    input_packets = File.readlines(@input_path, chomp: true).filter { |line| line != '' }.map do |serialized_packet|
      JSON.load(serialized_packet)
    end

    divider_packets = [
      [[2]],
      [[6]],
    ]

    packets = input_packets + divider_packets

    sorted_packets = packets.sort { |left, right| Problem.in_right_order?(left, right) ? -1 : 1 }

    start_index = sorted_packets.find_index { |packet| packet == [[2]] } + 1
    end_index = sorted_packets.find_index { |packet| packet == [[6]] } + 1

    start_index * end_index
  end

  private

  def self.in_right_order?(left, right)
    self.recursive_in_right_order?(left, right) do
      raise "left: #{left} and right: #{right} are equal, unsure what to do"
    end
  end

  def self.recursive_in_right_order?(left, right, &continuation)
    if left.is_a?(Integer) && right.is_a?(Integer)
      return true if left < right
      return false if left > right
      return continuation.call
    elsif left.is_a?(Array) && right.is_a?(Array)
      return true if left.empty? && !right.empty?
      return false if !left.empty? && right.empty?
      return continuation.call if left.empty? && right.empty?
      return self.recursive_in_right_order?(left.first, right.first) do
        self.recursive_in_right_order?(left.drop(1), right.drop(1), &continuation)
      end
    else
      left_array = left.is_a?(Integer) ? [left] : left
      right_array = right.is_a?(Integer) ? [right] : right
      return self.recursive_in_right_order?(left_array, right_array, &continuation)
    end
  end
end
