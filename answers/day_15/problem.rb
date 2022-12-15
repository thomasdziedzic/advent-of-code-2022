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
      positions_covered_at_y = Set.new
      beacon_positions_at_y = Set.new
      sensor_positions_at_y = Set.new

      @sensors.each do |sensor|
        beacon_positions_at_y << sensor.closest_beacon_position.x if sensor.closest_beacon_position.y == y
        sensor_positions_at_y << sensor.sensor_position.x if sensor.sensor_position.y == y

        distance = sensor.manhatten_distance_to_closest_beacon
        distance_to_y = (sensor.sensor_position.y - y).abs
        distance_left = distance - distance_to_y
        if distance_left >= 0
          positions_covered_at_y_by_sensor = Set.new(((sensor.sensor_position.x - distance_left)..(sensor.sensor_position.x + distance_left)).to_a)
          positions_covered_at_y.merge(positions_covered_at_y_by_sensor)
        end
      end

      positions_covered_at_y.count - beacon_positions_at_y.count - sensor_positions_at_y.count
    end
  end
end
