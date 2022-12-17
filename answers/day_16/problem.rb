require 'rgl/adjacency'
require 'rgl/dijkstra'
# require 'rgl/transitivity'
# require 'rgl/dot'

module RGL
  module Graph
    def time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits(time_budget, time_to_sell, time_to_travel_between_adjacent_locations, starting_vertex, profits_by_vertex)
      shortest_paths = vertices.map do |source_vertex|
        [source_vertex, dijkstra_shortest_paths(Hash.new(time_to_travel_between_adjacent_locations), source_vertex).map { |k, v| [k, v.length - 1] }.to_h]
      end.to_h

      candidate_locations = vertices.filter_map do |vertex|
        next if profits_by_vertex[vertex].zero?
        vertex
      end.to_set

      initial_profit = 0
      seen_location_profits = {}

      time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits_helper(candidate_locations, seen_location_profits, initial_profit, time_budget, time_to_sell, time_to_travel_between_adjacent_locations, starting_vertex, profits_by_vertex, shortest_paths)
    end

    private

    def time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits_helper(candidate_locations, seen_location_profits, current_profit, time_left, time_to_sell, time_to_travel_between_adjacent_locations, current_vertex, profits_by_vertex, shortest_paths)
      return current_profit if candidate_locations.empty? || time_left <= time_to_sell || seen_location_profits[current_vertex] == current_profit
      old_seen_location_profit = seen_location_profits[current_vertex]
      seen_location_profits[current_vertex] = current_profit

      other_candidate_locations = candidate_locations - Set[current_vertex]

      max_profits_if_sold_to_current_location = if candidate_locations.include?(current_vertex)
        # the current location has value in potentially selling to
        potential_profits_for_current_location = (time_left - time_to_sell) * profits_by_vertex[current_vertex]

        other_candidate_locations.map do |candidate_location|
          time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits_helper(
            other_candidate_locations,
            seen_location_profits,
            current_profit + potential_profits_for_current_location,
            time_left - time_to_sell - shortest_paths[current_vertex][candidate_location],
            time_to_sell,
            time_to_travel_between_adjacent_locations,
            candidate_location,
            profits_by_vertex,
            shortest_paths
          )
        end.max || current_profit + potential_profits_for_current_location
      else
        current_profit
      end

      max_profits_if_not_sold_to_current_location = other_candidate_locations.map do |candidate_location|
        time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits_helper(
          candidate_locations,
          seen_location_profits,
          current_profit,
          time_left - shortest_paths[current_vertex][candidate_location],
          time_to_sell,
          time_to_travel_between_adjacent_locations,
          candidate_location,
          profits_by_vertex,
          shortest_paths
        )
      end.max || current_profit

      seen_location_profits[current_vertex] = old_seen_location_profit

      [max_profits_if_sold_to_current_location, max_profits_if_not_sold_to_current_location].max
    end
  end
end

class Problem
  def initialize(input_filename)
    input_path = File.join(File.dirname(__FILE__), input_filename)
    @valves = File.readlines(input_path, chomp: true).map do |line|
      m = line.match(/Valve (.*) has flow rate=(.*); tunnels? leads? to valves? (.*)/)
      Valve.new(m[1], m[2].to_i, m[3].split(', '))
    end
  end

  def answer_part_1
    cost_to_open_valve = 1
    cost_to_follow_tunnel = 1
    time_budget = 30
    start_valve = 'AA'

    pressure_system = PressureSystem.new(cost_to_open_valve, cost_to_follow_tunnel, @valves)
    pressure_system.most_pressure_that_can_be_released(time_budget, start_valve)
  end

  def answer_part_2
  end

  Valve = Struct.new(:label, :flow_rate, :leads_to_valves)

  class PressureSystem
    def initialize(cost_to_open_valve, cost_to_follow_tunnel, valves)
      @cost_to_open_valve = cost_to_open_valve
      @cost_to_follow_tunnel = cost_to_follow_tunnel

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

    def most_pressure_that_can_be_released(time_budget, start_valve)
      @graph.time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits(time_budget, @cost_to_open_valve, @cost_to_follow_tunnel, start_valve, @flow_rates)
    end
  end
end
