if ARGV.length == 0
  puts "This script requires one argument representing the day to get the answers for, and an optional input filename"
  exit 1
end

require 'active_support/all'
require 'debug'

day = ARGV.first
input_filename = ARGV.second || 'input'

require_relative "../answers/day_#{day}/problem"

problem = Problem.new(input_filename)

puts "The answer for part 1 is: #{problem.answer_part_1}"
puts "The answer for part 2 is: #{problem.answer_part_2}"
