class Problem
  def initialize
    @input_path = File.join(File.dirname(__FILE__), 'input')
  end

  def answer_part_1
    File.readlines(@input_path).map { |line| line.chomp }.split('').map { |group| group.map(&:to_i).sum }.max
  end

  def answer_part_2
    File.readlines(@input_path).map { |line| line.chomp }.split('').map { |group| group.map(&:to_i).sum }.sort.reverse.first(3).sum
  end
end
