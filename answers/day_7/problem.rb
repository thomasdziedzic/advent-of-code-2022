class Problem
  def initialize
    input_path = File.join(File.dirname(__FILE__), 'input')
    @session = Session.parse(input_path)
  end

  def answer_part_1
    all_directory_sizes(@session.filesystem).filter { |size| size <= 100_000 }.sum
  end

  def answer_part_2
    directory_sizes = all_directory_sizes(@session.filesystem)
    total_used_space = directory_sizes.last
    total_disk_space = 70_000_000
    total_needed_unused_space = 30_000_000
    needed_to_delete = total_used_space - (total_disk_space - total_needed_unused_space)
    directory_sizes.filter { |size| size >= needed_to_delete }.sort.first
  end

  def all_directory_sizes(hash)
    results = []
    size = 0

    hash.each do |key, value|
      if value.is_a?(Hash)
        # directory
        subdirectory_sizes = all_directory_sizes(value)
        results += subdirectory_sizes
        size += subdirectory_sizes.last
      else
        # file
        size += value
      end
    end

    results << size

    results
  end

  class Session
    attr_reader :filesystem

    def initialize
      @pwd = []
      @filesystem = {}
    end

    def local_directory
      if @pwd.empty?
        @filesystem
      else
        @filesystem.dig(*@pwd)
      end
    end

    def change_directory(directory)
      if directory == '/'
        @pwd = []
      elsif directory == '..'
        @pwd.pop
      else
        @pwd << directory
      end
    end

    def self.parse(input_path)
      input = File.readlines(input_path, chomp: true)
      session = Session.new

      while !input.empty?
        command_string = input.shift
        if command_string.match?(/\$\s*ls\s*/)
          ls_output = input.take_while { |line| !line.match?(/\$.*/) }
          input.shift(ls_output.size)

          ls_output.each do |ls_output_line|
            if m = ls_output_line.match(/dir (\w+)/)
              dir_name = m[1]
              session.local_directory[dir_name] ||= {}
            elsif m = ls_output_line.match(/(\d+) (.*)/)
              file_size = m[1].to_i
              file_name = m[2]
              session.local_directory[file_name] = file_size
            else
              raise "failed to parse ls output line #{ls_output_line.inspect}"
            end
          end
        elsif command_match = command_string.match(/\$\s*cd\s*(.*)/)
          new_directory = command_match[1]
          session.change_directory(new_directory)
        else
          raise "failed to parse command_string #{command_string.inspect}"
        end
      end

      session
    end
  end
end
