require 'rgl/adjacency'
require 'rgl/dijkstra'
require 'algorithms'

$enable_logging = false

module RGL
  module Graph
    def time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits(num_salesmen, time_budget, starting_vertex, profits_by_vertex)
      shortest_paths = vertices.map do |source_vertex|
        [source_vertex, dijkstra_shortest_paths(Hash.new(1), source_vertex).map { |k, v| [k, v.length - 1] }.to_h]
      end.to_h

      candidate_locations = vertices.filter { |vertex| profits_by_vertex[vertex].nonzero? }.to_set
      cache = Containers::Trie.new

      initial_profit = 0
      salesmen = (0...num_salesmen).map { |salesman_index| Salesman.new(0, time_budget, starting_vertex, [starting_vertex], salesman_index) }

      time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits_helper(salesmen, initial_profit, candidate_locations, profits_by_vertex, shortest_paths, cache)
    end

    private

    Salesman = Struct.new(:profit, :time_left, :current_vertex, :path, :label)

    def time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits_helper(salesmen, total_profit, candidate_locations, profits_by_vertex, shortest_paths, cache)
      return total_profit if candidate_locations.empty?

      puts "entering helper with salesmen: #{salesmen.inspect} total_profit #{total_profit} candidate_locations #{candidate_locations.inspect}" if $enable_logging

      key = salesmen.sort_by { |salesman| salesman.path }.map { |salesman| salesman.path.join }.join(";")
      cached_total_profit = cache[key]
      if cached_total_profit
        puts "seen key #{key} with previous profits of #{cached_total_profit}" if $enable_logging
        return cached_total_profit
      end

      max = salesmen.map do |salesman|
        next total_profit if salesman.time_left <= 2

        original_salesman_vertex = salesman.current_vertex

        max_profit_if_taken_candidate_location = candidate_locations.map do |candidate_location|
          time_to_travel_and_sell_to_candidate_location = 1 + shortest_paths[salesman.current_vertex][candidate_location]
          next total_profit if salesman.time_left <= time_to_travel_and_sell_to_candidate_location # not enough time to release any pressure

          # the current location has value in potentially selling to
          potential_profits_for_candidate_location = (salesman.time_left - time_to_travel_and_sell_to_candidate_location) * profits_by_vertex[candidate_location]

          salesman.profit += potential_profits_for_candidate_location
          salesman.time_left -= time_to_travel_and_sell_to_candidate_location
          salesman.current_vertex = candidate_location
          salesman.path << candidate_location
          puts "salesman #{salesman.label}: opening #{original_salesman_vertex} and moving to #{salesman.path.inspect}" if $enable_logging

          profit_if_taken = time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits_helper(
            salesmen,
            total_profit + potential_profits_for_candidate_location,
            candidate_locations - Set[candidate_location],
            profits_by_vertex,
            shortest_paths,
            cache
          )

          salesman.path.pop
          salesman.current_vertex = original_salesman_vertex
          salesman.time_left += time_to_travel_and_sell_to_candidate_location
          salesman.profit -= potential_profits_for_candidate_location

          profit_if_taken
        end.max

        original_time_left = salesman.time_left
        salesman.time_left = 0
        profit_if_stopped = time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits_helper(
          salesmen,
          total_profit,
          candidate_locations,
          profits_by_vertex,
          shortest_paths,
          cache
        )
        salesman.time_left = original_time_left

        [max_profit_if_taken_candidate_location, profit_if_stopped].max
      end.max

      cache[key] = max

      max
    end
  end
end

class Problem
  def initialize(input_filename, options)
    input_path = File.join(File.dirname(__FILE__), input_filename)
    @valves = File.readlines(input_path, chomp: true).map do |line|
      m = line.match(/Valve (.*) has flow rate=(.*); tunnels? leads? to valves? (.*)/)
      Valve.new(m[1], m[2].to_i, m[3].split(', '))
    end
    @options = options
    $enable_logging = @options['logging']
  end

  def answer_part_1
    time_budget = 30
    start_valve = 'AA'

    pressure_system = PressureSystem.new(@valves)
    pressure_system.most_pressure_that_can_be_released(1, time_budget, start_valve)
  end

  def answer_part_2
    time_budget = 26
    start_valve = 'AA'

    pressure_system = PressureSystem.new(@valves)
    pressure_system.most_pressure_that_can_be_released(2, time_budget, start_valve)
  end

  Valve = Struct.new(:label, :flow_rate, :leads_to_valves)

  class PressureSystem
    def initialize(valves)
      @graph = RGL::AdjacencyGraph.new
      @flow_rates = {}
      valves.each do |valve|
        @flow_rates[valve.label] = valve.flow_rate

        @graph.add_vertex(valve.label)
        valve.leads_to_valves.each do |leads_to_valve|
          @graph.add_edge(valve.label, leads_to_valve)
        end
      end
    end

    def most_pressure_that_can_be_released(num_salesmen, time_budget, start_valve)
      @graph.time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits(num_salesmen, time_budget, start_valve, @flow_rates)
    end
  end
end
