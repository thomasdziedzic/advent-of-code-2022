require 'rgl/adjacency'
require 'rgl/dijkstra'
# require 'rgl/transitivity'
# require 'rgl/dot'

module RGL
  module Graph
    def time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits(time_budget, starting_vertex, profits_by_vertex)
      shortest_paths = vertices.map do |source_vertex|
        [source_vertex, dijkstra_shortest_paths(Hash.new(1), source_vertex).map { |k, v| [k, v.length - 1] }.to_h]
      end.to_h

      candidate_locations = vertices.filter_map do |vertex|
        next if profits_by_vertex[vertex].zero?
        vertex
      end.to_set

      salesman = Salesman.new(0, {}, time_budget, starting_vertex)

      time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits_helper(salesman, candidate_locations, profits_by_vertex, shortest_paths)
    end

    private

    Salesman = Struct.new(:profit, :seen_location_profits, :time_left, :current_vertex)

    def time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits_helper(salesman, candidate_locations, profits_by_vertex, shortest_paths)
      return salesman.profit if candidate_locations.empty? || salesman.time_left <= 1 || salesman.seen_location_profits[salesman.current_vertex] == salesman.profit
      salesman.seen_location_profits[salesman.current_vertex] = salesman.profit

      other_candidate_locations = candidate_locations - Set[salesman.current_vertex]

      original_seen_location_profit = salesman.seen_location_profits[salesman.current_vertex]
      original_salesman_vertex = salesman.current_vertex

      max_profits = if candidate_locations.include?(salesman.current_vertex) && profits_by_vertex[salesman.current_vertex].nonzero?
        # the current location has value in potentially selling to
        potential_profits_for_current_location = (salesman.time_left - 1) * profits_by_vertex[salesman.current_vertex]

        other_candidate_locations.map do |candidate_location|
          salesman.profit += potential_profits_for_current_location
          salesman.time_left -= 1 + shortest_paths[salesman.current_vertex][candidate_location]
          salesman.current_vertex = candidate_location
          ret = time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits_helper(
            salesman,
            other_candidate_locations,
            profits_by_vertex,
            shortest_paths
          )
          salesman.current_vertex = original_salesman_vertex
          salesman.time_left += 1 + shortest_paths[salesman.current_vertex][candidate_location]
          salesman.profit -= potential_profits_for_current_location
          ret
        end.max || salesman.profit + potential_profits_for_current_location
      else
        other_candidate_locations.map do |candidate_location|
          salesman.time_left -= shortest_paths[salesman.current_vertex][candidate_location]
          salesman.current_vertex = candidate_location
          ret = time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits_helper(
            salesman,
            candidate_locations,
            profits_by_vertex,
            shortest_paths
          )
          salesman.current_vertex = original_salesman_vertex
          salesman.time_left += shortest_paths[salesman.current_vertex][candidate_location]
          ret
        end.max || salesman.profit
      end

      salesman.seen_location_profits[salesman.current_vertex] = original_seen_location_profit

      max_profits
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
    time_budget = 30
    start_valve = 'AA'

    pressure_system = PressureSystem.new(@valves)
    pressure_system.most_pressure_that_can_be_released(time_budget, start_valve)
  end

  def answer_part_2
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

    def most_pressure_that_can_be_released(time_budget, start_valve)
      @graph.time_bound_traveling_salesman_with_optional_selling_and_adjusting_profits(time_budget, start_valve, @flow_rates)
    end
  end
end
