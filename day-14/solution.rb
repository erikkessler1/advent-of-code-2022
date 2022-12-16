require_relative './../lib/runner'

class Day14 < Puzzle
  def self.part_1_sample
    [
      "498,4 -> 498,6 -> 496,6\n" \
      "503,4 -> 502,4 -> 502,9 -> 494,9",
      24
    ]
  end

  def self.part_2_sample
    [part_1_sample[0], 93]
  end

  def initialize(input)
    @rocks = input.split("\n").map do |line|
      line.split(" -> ").map do |point|
        point.split(",").map(&method(:Integer))
      end
    end
  end

  def solve_part_1
    cave = Cave.new(@rocks)
    cave.fill
    cave.sand_count
  end

  def solve_part_2
    rocks = [*@rocks, Cave.bottom(@rocks)]
    cave = Cave.new(rocks)
    cave.fill
    cave.sand_count
  end
end

class Cave
  def self.bottom(rocks)
    points = rocks.flat_map(&:itself)
    ys = points.map { |(_, y)| y }
    y_max = ys.max + 2

    x_start = 500 - y_max
    x_end = 500 + y_max

    [[x_start, y_max], [x_end, y_max]]
  end

  def initialize(rocks)
    @rocks = rocks
    fill_rocks
  end

  def corners
    return @corners if defined?(@corners)

    points = rocks.flat_map(&:itself)
    xs = points.map { |(x, _)| x }
    ys = points.map { |(_, y)| y }

    @corners = [
      [xs.min, 0],
      [xs.max, ys.max]
    ]
  end

  def fill(i = 2 ** 20)
    i.times do
      sand_y, sand_x = @fill_point
      loop do
        return if sand_y + 1 > corners[1][1]
        next sand_y += 1 if grid[sand_y + 1][sand_x] == '.'

        if grid[sand_y + 1][sand_x - 1] == '.'
          sand_y += 1
          sand_x -= 1
          next
        end

        if grid[sand_y + 1][sand_x + 1] == '.'
          sand_y += 1
          sand_x += 1
          next
        end

        grid[sand_y][sand_x] = 'o'
        break
      end
    end
  end

  def draw
    grid.each do |line|
      puts line.join
    end
  end

  def sand_count
    grid.flatten.count do |cell|
      cell == 'o'
    end
  end

  private

  attr_reader :rocks

  def fill_rocks
    x_offset, y_offset = corners[0]

    rocks.each do |trace|
      trace.drop(1).reduce(trace[0]) do |start_point, end_point|
        each_between(start_point, end_point) do |x, y|
          grid[y - y_offset][x - x_offset] = '#'
        end

        end_point
      end
    end

    @fill_point = [0, 500 - x_offset]
    grid[0][500 - x_offset] = '+'
  end

  def each_between((start_x, start_y), (end_x, end_y))
    if start_x == end_x
      a, b = [start_y, end_y].sort
      (a..b).each do |y|
        yield [start_x, y]
      end
    else
      a, b = [start_x, end_x].sort
      (a..b).each do |x|
        yield [x, start_y]
      end
    end
  end

  def grid
    @grid ||= Array.new((corners[1][1] - corners[0][1]) + 1) do
      Array.new((corners[1][0] - corners[0][0]) + 1) { '.' }
    end
  end
end

PuzzleRunner.run(Day14)
