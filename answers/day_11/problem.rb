class Problem
  def initialize
    @input_path = File.join(File.dirname(__FILE__), 'input')
  end

  def setup
    @monkeys = File.readlines(@input_path, chomp: true).split('').map do |lines|
      Monkey.parse(lines)
    end
  end

  def answer_part_1
    setup
    bored_lambda = lambda { |w| w / 3}
    round = Round.new(@monkeys, bored_lambda)
    20.times do
      round.perform
    end

    @monkeys.map(&:inspected_items).sort.reverse.first(2).inject(:*)
  end

  def answer_part_2
    setup
    multiplied_test_divisibly_by = @monkeys.map(&:test_divisible_by).inject(:*)
    bored_lambda = lambda { |w| w % multiplied_test_divisibly_by }
    round = Round.new(@monkeys, bored_lambda)

    10_000.times do |round_num|
      round.perform
    end

    @monkeys.map(&:inspected_items).sort.reverse.first(2).inject(:*)
  end

  class Monkey
    attr_reader :inspected_items
    attr_reader :test_divisible_by

    def initialize(starting_items:, first_operand:, operation:, second_operand:, test_divisible_by:, throw_to_true_monkey:, throw_to_false_monkey:)
      @items = starting_items
      @first_operand = first_operand
      @operation = operation
      @second_operand = second_operand
      @test_divisible_by = test_divisible_by
      @throw_to_true_monkey = throw_to_true_monkey
      @throw_to_false_monkey = throw_to_false_monkey
      @inspected_items = 0
    end

    def throw_items(worry_level_after_monkey_gets_bored)
      ret = []
      @items.each do |item|
        new_worry_level = @operation.call(@first_operand.call(item), @second_operand.call(item))
        bored_worry_level = worry_level_after_monkey_gets_bored.call(new_worry_level)
        if bored_worry_level % @test_divisible_by == 0
          ret << [@throw_to_true_monkey, bored_worry_level]
        else
          ret << [@throw_to_false_monkey, bored_worry_level]
        end
      end
      @inspected_items += @items.size
      @items = []

      ret
    end

    def catch_item(item)
      @items << item
    end

    def self.parse(lines)
      m = lines[1].match(/Starting items: (.*)/)
      starting_items = m[1].split(', ').map(&:to_i)

      m = lines[2].match(/Operation: new = (.*)/)
      operation_string = m[1]
      tokens = m[1].split
      first_operand =
        case tokens[0]
        when 'old'
          lambda { |old| old }
        else
          lambda { |old| tokens[0].to_i }
        end
      operation =
        case tokens[1]
        when '+'
          lambda { |left, right| left + right }
        when '*'
          lambda { |left, right| left * right }
        else
          raise "Unknown operation #{tokens[1]}"
        end
      second_operand =
        case tokens[2]
        when 'old'
          lambda { |old| old }
        else
          lambda { |old| tokens[2].to_i }
        end

      m = lines[3].match(/Test: divisible by (\d+)/)
      test_divisible_by = m[1].to_i

      m = lines[4].match(/If true: throw to monkey (\d+)/)
      throw_to_true_monkey = m[1].to_i

      m = lines[5].match(/If false: throw to monkey (\d+)/)
      throw_to_false_monkey = m[1].to_i

      Monkey.new(
        starting_items: starting_items,
        first_operand: first_operand,
        operation: operation,
        second_operand: second_operand,
        test_divisible_by: test_divisible_by,
        throw_to_true_monkey: throw_to_true_monkey,
        throw_to_false_monkey: throw_to_false_monkey
      )
    end
  end

  class Round
    def initialize(monkeys, bored_lambda)
      @monkeys = monkeys
      @bored_lambda = bored_lambda
    end

    def perform
      @monkeys.each do |monkey|
        monkey.throw_items(@bored_lambda).each do |throw_item|
          receiving_monkey_id, item = throw_item
          receiving_monkey = @monkeys[receiving_monkey_id]
          receiving_monkey.catch_item(item)
        end
      end
    end
  end
end
