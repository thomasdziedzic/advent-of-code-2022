class Problem
  def initialize
    input_path = File.join(File.dirname(__FILE__), 'input')
    @program = File.readlines(input_path, chomp: true).map do |line|
      if (m = line.match(/addx (-?\d+)/))
        AddX.new(m[1].to_i)
      elsif (m = line.match(/noop/))
        Noop.new
      else
        raise "Unable to parse #{line.inspect} into an instruction"
      end
    end
  end

  def answer_part_1
    cpu = CPU.new(1, [20, 60, 100, 140, 180, 220])
    cpu.run(@program)
    cpu.recorded_signals.sum
  end

  def answer_part_2
    cpu = CPU.new(1, [])
    cpu.run(@program)
    cpu.crt
  end

  class AddX
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def cycles
      2
    end
  end

  class Noop
    def cycles
      1
    end
  end

  class CPU
    attr_reader :recorded_signals, :crt

    def initialize(initial_x, record_cycles)
      @x = initial_x
      @record_cycles = record_cycles
      @recorded_signals = []
      @crt = "\n"
    end

    def run(program)
      crt_line_index = 0
      cycles = 0

      program.each do |instruction|
        instruction.cycles.times do
          cycles += 1

          if @record_cycles.first && @record_cycles.first <= cycles
            signal_strength = @record_cycles.first * @x
            @recorded_signals << signal_strength
            @record_cycles.shift
          end

          if (@x - 1) <= crt_line_index && crt_line_index <= (@x + 1)
            @crt += '#'
          else
            @crt += '.'
          end

          crt_line_index += 1
          if crt_line_index == 40
            @crt += "\n"
            crt_line_index = 0
          end
        end

        case instruction
        when AddX
          @x += instruction.value
        when Noop
        else
          raise "Unknown instruction #{instruction.inspect}"
        end
      end
    end
  end
end
