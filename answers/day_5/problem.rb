class Problem
  class StackConfiguration
    def initialize(stacks)
      @stacks = stacks
    end

    def perform(move)
      move.quantity.times do
        from_index = move.from - 1
        to_index = move.to - 1

        crate = @stacks[from_index].shift

        @stacks[to_index].unshift(crate)
      end
    end

    def perform_9001(move)
      from_index = move.from - 1
      to_index = move.to - 1

      crates = @stacks[from_index].shift(move.quantity)

      @stacks[to_index].unshift(crates).flatten!
    end

    def top_of_stacks
      @stacks.map { |stack| stack.first }.join
    end

    def self.parse(input)
      stack_lines = input[0, input.length - 1]
      label_line = input[-1]

      num_labels = label_line.match(/(?:\s*(\d+)\s*)*/)[1].to_i

      stacks = Array.new(num_labels) { [] }
      stack_lines.each do |stack_line|
        num_labels.times do |i|
          start_index = i * 4
          crate = stack_line[start_index, 3][1]
          if crate.present?
            stacks[i] << crate
          end
        end
      end

      StackConfiguration.new(stacks)
    end
  end

  class Move
    MOVE_FORMAT = /move (?<quantity>\d+) from (?<from>\d+) to (?<to>\d+)/

    attr_reader :quantity, :from, :to

    def initialize(quantity:, from:, to:)
      @quantity = quantity
      @from = from
      @to = to
    end

    def self.parse(input)
      m = input.match(MOVE_FORMAT)

      quantity = m[:quantity].to_i
      from = m[:from].to_i
      to = m[:to].to_i

      Move.new(quantity: quantity, from: from, to: to)
    end
  end

  def initialize
    input_path = File.join(File.dirname(__FILE__), 'input')
    @stack_configuration_input, moves_input = File.readlines(input_path, chomp: true).split('')
    @moves = moves_input.map { |move_input| Move.parse(move_input) }
  end

  def answer_part_1
    stack_configuration = StackConfiguration.parse(@stack_configuration_input)

    @moves.each do |move|
      stack_configuration.perform(move)
    end

    stack_configuration.top_of_stacks
  end

  def answer_part_2
    stack_configuration = StackConfiguration.parse(@stack_configuration_input)

    @moves.each do |move|
      stack_configuration.perform_9001(move)
    end

    stack_configuration.top_of_stacks
  end
end
