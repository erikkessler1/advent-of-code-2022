require_relative './../lib/runner'

class Day15 < Puzzle
  def self.part_1_sample
    [[sample, 10], 26]
  end

  def self.part_2_sample
    [[sample, 20], 56000011]
  end

  def initialize(input)
    @sensors = input.split("\n").map do |line|
      match_data = /Sensor at x=(.*), y=(.*): closest beacon is at x=(.*), y=(.*)/.match(line)
      match_data[1..-1].map(&method(:Integer))
      sensor_x, sensor_y, beacon_x, beacon_y = match_data[1..-1].map(&method(:Integer))
      Sensor.new(sensor_x, sensor_y, beacon: [beacon_x, beacon_y])
    end
  end

  def solve_part_1(line = 2_000_000)
    @sensors.flat_map do |sensor|
      start_x = sensor.x - sensor.distance
      end_x = sensor.x + sensor.distance
      away  = (line - sensor.y).abs

      target_start_x = start_x + away
      target_end_x = end_x - away
      (target_start_x..target_end_x).to_a
    end.uniq.reject do |x|
      @sensors.any? do |sensor|
        sensor.beacon?(x, line)
      end
    end.size
  end

  def solve_part_2(max = 4_000_000)
    max.times do |line|
      # Want to see progress
      p line if (line % 100_000).zero?

      ranges =  @sensors.map do |sensor|
        start_x = sensor.x - sensor.distance
        end_x = sensor.x + sensor.distance
        away  = (line - sensor.y).abs

        target_start_x = start_x + away
        target_end_x = end_x - away
        next if target_end_x < target_start_x

        [target_start_x, target_end_x]
      end.compact.sort_by { |(s, e)| s }

      ranges.reduce(0) do |current_x, (start_x, end_x)|
        next [current_x, end_x].max if start_x <= current_x

        return (4_000_000 * (current_x + 1)) + line
      end
    end

    nil
  end
end

class Sensor
  def initialize(x, y, beacon:)
    @x = x
    @y = y
    @beacon_x, @beacon_y = beacon
  end

  attr_reader :x,
              :y

  def beacon?(x, y)
    x == @beacon_x && y == @beacon_y
  end

  def distance
    return @distance if defined?(@distance)

    dx = (@beacon_x - @x).abs
    dy = (@beacon_y - @y).abs

    @distance = dx + dy
  end
end

PuzzleRunner.run(Day15)
