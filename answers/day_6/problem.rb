class Problem
  def initialize
    input_path = File.join(File.dirname(__FILE__), 'input')
    @signal = File.readlines(input_path, chomp: true).first
  end

  def answer_part_1
    @signal.split('').each_cons(4).each_with_index do |window, index|
      return index + 4 if Set.new(window).size == 4
    end
  end

  def answer_part_2
    @signal.split('').each_cons(14).each_with_index do |window, index|
      return index + 14 if Set.new(window).size == 14
    end
  end
end
