if ARGV.length == 0
  puts "This script requires one argument representing the day to get the answers for, and an input filename"
  exit 1
end

require 'active_support/all'
require 'debug'

day, input_filename, *flags = ARGV

options = flags.map do |flag|
  k, v = flag.split('=')

  if v == "true"
    v = true
  elsif v == "false"
    v = false
  end

  [k, v]
end.to_h

require_relative "../answers/day_#{day}/problem"

problem = Problem.new(input_filename, options)

starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
puts "The answer for part 1 is: #{problem.answer_part_1}"
ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
puts "The elapsed time for part 1 is: #{ending - starting}"

starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
puts "The answer for part 2 is: #{problem.answer_part_2}"
ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
puts "The elapsed time for part 2 is: #{ending - starting}"
