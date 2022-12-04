class Problem
  def initialize
    @input_path = File.join(File.dirname(__FILE__), 'input')
  end

  def answer_part_1
    File.readlines(@input_path).map { |line| line.chomp }.flat_map { |rucksack| Problem.common_item_types(rucksack) }.map { |item| Problem.item_priority[item] }.sum
  end

  def answer_part_2
    File.readlines(@input_path).map { |line| line.chomp }.in_groups_of(3, false).flat_map { |group| Problem.common_item_types_in_group(group) }.map { |item| Problem.item_priority[item] }.sum
  end

  private

  def self.item_priority
    @@item_priority ||= begin
      a_to_Z = ('a'..'z').to_a + ('A'..'Z').to_a
      a_to_Z.zip(1..).to_h
    end
  end

  def self.split_in_half(xs)
    items_per_compartment = xs.length / 2
    [xs[0...items_per_compartment], xs[items_per_compartment...xs.length]]
  end

  def self.common_item_types(rucksack)
    left_compartment, right_compartment = split_in_half(rucksack)
    left_compartment.split('') & right_compartment.split('')
  end

  def self.common_item_types_in_group(group)
    group[0].split('') & group[1].split('') & group[2].split('')
  end
end
