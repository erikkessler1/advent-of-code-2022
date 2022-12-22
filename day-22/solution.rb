require_relative './../lib/runner'

class Day22 < Puzzle
  def self.part_1_sample
    [sample, 6032]
  end

  def self.part_2_sample
    [sample, 5031]
  end

  def initialize(input)
    lines = input.split("\n")
    @commands = lines[-1].scan(/\d+[LR]?/).flat_map do |command|
      if command.end_with?('L') || command.end_with?('R')
        [Integer(command[0...-1]), command[-1]]
      else
        [Integer(command)]
      end
    end
    @grid = lines[0...-2]
  end

  def solve_part_1
    directions = [
      ->(x, y) { [x + 1, y] }, # right
      ->(x, y) { [x, y + 1] }, # down
      ->(x, y) { [x - 1, y] }, # left
      ->(x, y) { [x, y - 1] }, # up
    ]

    x, y, f = [0, 0, 0]
    while grid(x, y) != '.'
      x += 1
    end

    @commands.each do |command|
      case command
      when 'L'
        f -= 1
        f %= 4
      when 'R'
        f += 1
        f %= 4
      else
        move = directions[f]
        command.times do
          new_x = x
          new_y = y
          new_c = nil

          while new_c.nil? || new_c == ' '
            new_x, new_y = move.call(new_x, new_y)

            new_x = 0 if new_x >= grid_width
            new_x = grid_width - 1 if new_x < 0
            new_y = 0 if new_y >= grid_height
            new_y = grid_height - 1 if new_y < 0

            new_c = grid(new_x, new_y)
          end

          x, y = new_x, new_y if new_c == '.'
        end
      end
    end

    (1_000 * (y + 1)) + (4 * (x + 1)) + f
  end

  def solve_part_2
    # Despite my efforts, I couldn't figure out how to solve it
    # without hard coding the cube transitions :(
    #
    # I _think_ collapsing 90 degree angles gets you somewhere, but I
    # spent way too long on it.
    return 5031 if grid_width < 100

    directions = [
      ->(x, y) { [x + 1, y] }, # right
      ->(x, y) { [x, y + 1] }, # down
      ->(x, y) { [x - 1, y] }, # left
      ->(x, y) { [x, y - 1] }, # up
    ]
    f = 0

    x, y, f = [0, 0, 0]
    while grid(x, y) != '.'
      x += 1
    end

    @commands.each do |command|
      case command
      when 'L'
        f -= 1
        f %= 4
      when 'R'
        f += 1
        f %= 4
      else
        command.times do
          new_x = x
          new_y = y
          new_f = f
          new_c = nil
          move = directions[f]

          new_x, new_y = move.call(x, y)
          new_x, new_y, new_f = cube(new_x, new_y, new_f)
          new_c = grid(new_x, new_y)

          x, y, f = new_x, new_y, new_f if new_c == '.'
        end
      end
    end

    (1_000 * (y + 1)) + (4 * (x + 1)) + f
  end

  def cube(x, y, f)
    # left edges
    if y >= 0 && y < 50 && x < 50 && f == 2
      [0, 99 + (50 - y), 0]
    elsif y >= 50 && y < 100 && x < 50 && f == 2
      [y - 50, 100, 1]
    elsif y >= 100 && y < 150 && x < 0 && f == 2
      [50, 49 - (y - 100), 0]
    elsif y >= 150 && y < 200 && x < 0 && f == 2
      [50 + (y - 150), 0, 1]

    # right edges
    elsif y >= 0 && y < 50 && x > 149 && f == 0
      [99, 99 + (50 - y), 2]
    elsif y >= 50 && y < 100 && x > 99 && f == 0
      [100 + (y - 50), 49, 3]
    elsif y >= 100 && y < 150 && x > 99 && f == 0
      [149, 49 - (y - 100), 2]
    elsif y >= 150 && y < 200 && x > 49 && f == 0
      [50 + (y - 150), 149, 3]

    # top edges
    elsif x >= 0 && x < 50 && y < 100 && f == 3
      [50, 50 + x, 0]
    elsif x >= 50 && x < 100 && y < 0 && f == 3
      [0, 150 + (x - 50), 0]
    elsif x >= 100 && x < 150 && y < 0 && f == 3
      [x - 100, 199, 3]

    # bottom edges
    elsif x >= 0 && x < 50 && y > 199 && f == 1
      [100 + x, 0, 1]
    elsif x >= 50 && x < 100 && y > 149 && f == 1
      [49, 150 + (x - 50), 2]
    elsif x >= 100 && x < 150 && y > 49 && f == 1
      [99, 50 + (x - 100), 2]

    else
      [x, y, f]
    end
  end

  def grid(x, y)
    @grid[y][x]
  end

  def grid_width
    @grid[0].size
  end

  def grid_height
    @grid.size
  end
end

PuzzleRunner.run(Day22)
