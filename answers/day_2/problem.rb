class Problem
  def initialize
    @input_path = File.join(File.dirname(__FILE__), 'input')
  end

  def answer_part_1
    File.readlines(@input_path).map { |line| Problem.calculate_points(line.chomp.split) }.sum
  end

  def answer_part_2
    File.readlines(@input_path).map { |line| Problem.calculate_points_from_opponents_hand_and_needed_outcome(line.chomp.split) }.sum
  end

  private

  def self.calculate_points(pair)
    opponent, player = pair
    points_guide_for_shape_selected = {
      'X' => 1,
      'Y' => 2,
      'Z' => 3,
    }
    lost_points = 0
    draw_points = 3
    won_points = 6
    points_guide_for_outcome_of_round = {
      'A' => {
        'X' => draw_points,
        'Y' => won_points,
        'Z' => lost_points,
      },
      'B' => {
        'X' => lost_points,
        'Y' => draw_points,
        'Z' => won_points,
      },
      'C' => {
        'X' => won_points,
        'Y' => lost_points,
        'Z' => draw_points,
      },
    }

    points_guide_for_shape_selected[player] + points_guide_for_outcome_of_round[opponent][player]
  end

  def self.calculate_points_from_opponents_hand_and_needed_outcome(pair)
    opponent, outcome_needed = pair

    rock_points = 1
    paper_points = 2
    scissors_points = 3
    point_guide_for_shape_derived_from_opponent_and_outcome_needed = {
      'A' => {
        'X' => scissors_points,
        'Y' => rock_points,
        'Z' => paper_points,
      },
      'B' => {
        'X' => rock_points,
        'Y' => paper_points,
        'Z' => scissors_points,
      },
      'C' => {
        'X' => paper_points,
        'Y' => scissors_points,
        'Z' => rock_points,
      },
    }

    lost_points = 0
    draw_points = 3
    won_points = 6
    point_guide_for_outcome = {
      'X' => lost_points,
      'Y' => draw_points,
      'Z' => won_points,
    }

    point_guide_for_shape_derived_from_opponent_and_outcome_needed[opponent][outcome_needed] + point_guide_for_outcome[outcome_needed]
  end
end
