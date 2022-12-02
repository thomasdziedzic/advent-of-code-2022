if ARGV.length != 1
  puts "This script requires one argument representing the day to get the answers for."
  exit 1
end

require 'active_support/all'

day = ARGV.first

require_relative "../answers/day_#{day}/problem"

problem = Problem.new

puts "The answer for part 1 is: #{problem.answer_part_1}"
puts "The answer for part 2 is: #{problem.answer_part_2}"
