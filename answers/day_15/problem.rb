require 'rgl/adjacency'
require 'rgl/transitivity'

class Problem
  def initialize(input_filename)
    input_path = File.join(File.dirname(__FILE__), input_filename)
    @sensors = File.readlines(input_path, chomp: true).map do |line|
      m = line.match(/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/)
      sensor_position = Position.new(m[1].to_i, m[2].to_i)
      closest_beacon_position = Position.new(m[3].to_i, m[4].to_i)
      Sensor.new(sensor_position, closest_beacon_position)
    end

    if input_filename == 'input'
      @y = 2_000_000
    elsif input_filename == 'demo_input'
      @y = 10
    else
      raise "Unknown input filename #{input_filename}"
    end
  end

  def answer_part_1
    zone = Zone.new(@sensors)
    zone.number_of_positions_that_cannot_contain_beacon(@y)
  end

  def answer_part_2
  end

  class Position
    attr_reader :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def manhatten_distance(other_position)
      (@x - other_position.x).abs + (@y - other_position.y).abs
    end
  end

  class Sensor
    attr_reader :sensor_position, :closest_beacon_position

    def initialize(sensor_position, closest_beacon_position)
      @sensor_position = sensor_position
      @closest_beacon_position = closest_beacon_position
    end

    def manhatten_distance_to_closest_beacon
      @sensor_position.manhatten_distance(@closest_beacon_position)
    end
  end

  class Zone
    def initialize(sensors)
      @sensors = sensors
    end

    def number_of_positions_that_cannot_contain_beacon(y)
      ranges_covered_at_y = []
      graph = RGL::AdjacencyGraph.new
      beacon_positions_at_y = Set.new
      sensor_positions_at_y = Set.new

      @sensors.each do |sensor|
        beacon_positions_at_y << sensor.closest_beacon_position.x if sensor.closest_beacon_position.y == y
        sensor_positions_at_y << sensor.sensor_position.x if sensor.sensor_position.y == y

        distance = sensor.manhatten_distance_to_closest_beacon
        distance_to_y = (sensor.sensor_position.y - y).abs
        distance_left = distance - distance_to_y
        if distance_left >= 0
          graph.add_vertex(ranges_covered_at_y.size)

          range_covered_at_y_by_sensor = (sensor.sensor_position.x - distance_left)..(sensor.sensor_position.x + distance_left)
          ranges_covered_at_y.each.with_index do |range_covered_at_y, range_covered_at_y_index|
            if range_covered_at_y.overlaps?(range_covered_at_y_by_sensor)
              graph.add_edge(range_covered_at_y_index, ranges_covered_at_y.size)
            end
          end
          ranges_covered_at_y << range_covered_at_y_by_sensor
        end
      end

      merged_ranges = []

      graph.each_connected_component do |connected_component|
        min = nil
        max = nil

        connected_component.map do |index|
          range = ranges_covered_at_y[index]

          min = [min, range.begin].compact.min
          max = [max, range.end].compact.max
        end

        merged_ranges << (min..max)
      end

      positions_covered_at_y = merged_ranges.map(&:count).sum
      overlapping_beacon_positions_at_y = beacon_positions_at_y.filter { |beacon_position_at_y| merged_ranges.any? { |merged_range| merged_range.include?(beacon_position_at_y) } }.count
      overlapping_sensor_positions_at_y = sensor_positions_at_y.filter { |sensor_position_at_y| merged_ranges.any? { |merged_range| merged_range.include?(sensor_position_at_y) } }.count
      positions_covered_at_y - overlapping_beacon_positions_at_y - overlapping_sensor_positions_at_y
    end
  end
end
