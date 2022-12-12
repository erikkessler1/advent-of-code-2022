require_relative './../lib/runner'

class Day12 < Puzzle
  def self.part_1_sample
    [File.read('sample.txt'), 31]
  end

  def self.part_2_sample
    [part_1_sample[0], 29]
  end

  def initialize(input)
    @hill = input.split("\n").map do |line|
      line.split("")
    end.then do |grid|
      Hill.new(grid)
    end
  end

  def solve_part_1
    Climber.climb(hill)
  end

  def solve_part_2
    hill.all_points.map do |point|
      next unless point.z.zero?

      Climber.climb(hill, start_point: point)
    end.compact.min
  end

  private

  attr_reader :hill
end

class Hill
  Point = Struct.new(:x, :y, :z)

  def initialize(grid)
    @grid = grid.each_with_index.map do |row, y|
      row.each_with_index.map do |cell, x|
        point = Point.new(x, y, nil)

        if cell == 'S'
          @start_point = point
          cell = 'a'
        end

        if cell == 'E'
          @end_point = point
          cell = 'z'
        end

        point.z = cell.ord - 97
        point
      end
    end
  end

  def adjacent_points(point)
    x = point.x
    y = point.y
    [
      [y + 1, x],
      [y, x + 1],
      [y - 1, x],
      [y, x - 1]
    ].map do |target_y, target_x|
      next if target_y.negative? || target_x.negative?
      next if grid[target_y].nil?

      grid[target_y][target_x]
    end.compact
  end

  def all_points
    grid.flatten
  end

  attr_reader :start_point,
              :end_point

  private

  attr_reader :grid
end

class Climber
  def self.climb(hill, start_point: hill.start_point)
    climber = new(hill)
    climber.climb(start_point: start_point)
  end

  def initialize(hill)
    @hill = hill
  end

  def climb(start_point: hill.start_point)
    forks[start_point] = 0

    while forks.any?
      current_point, step_count = guess_fork!

      next_points = hill.adjacent_points(current_point)
                      .select(&reachable?(from: current_point))
                      .select(&not_reached_closer?(than: step_count))

      next_points.each do |point|
        return step_count if point == hill.end_point

        forks[point] = step_count
      end
    end
  end

  private

  attr_reader :hill

  # Take the fork that seems best: lowest steps + estimated distance
  # to the end point.
  def guess_fork!
    forks.to_a.sort_by do |point, step_count|
      step_count + distances[point]
    end.first.tap do |point, _|
      forks.delete(point)
    end.then do |point, step_count|
      seen_forks[point] = step_count
      [point, step_count + 1]
    end
  end

  def reachable?(from:)
    ->(point) { point.z <= (from.z + 1) }
  end

  def not_reached_closer?(than:)
    ->(point) do
      seen_at = forks[point] || seen_forks[point]
      next true if seen_at.nil?

      than < seen_at
    end
  end

  def forks
    @forks ||= {}
  end

  def seen_forks
    @seen_forks ||= {}
  end

  def distances
    @distances ||= Hash.new do |distances, point|
      end_point = hill.end_point
      dx = end_point.x - point.x
      dy = end_point.y - point.y
      dz = end_point.z - point.z

      distances[point] = (dx ** 2) + (dy ** 2) + (dz ** 2)
    end
  end
end

PuzzleRunner.run(Day12)
