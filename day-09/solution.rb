require_relative './../lib/runner'

class Day09 < Puzzle
  def self.part_1_sample
    [<<~INPUT, 13]
      R 4
      U 4
      L 3
      D 1
      R 4
      D 1
      L 5
      R 2
    INPUT
  end

  def self.part_2_sample
    [<<~INPUT, 36]
      R 5
      U 8
      L 8
      D 3
      R 17
      D 10
      L 25
      U 20
    INPUT
  end

  def initialize(input)
    @commands = input.split("\n").map do |command|
      direction, amount = command.split(" ")
      [direction, Integer(amount)]
    end
  end

  def solve_part_1
    solve(rope_size: 2)
  end

  def solve_part_2
    solve(rope_size: 10)
  end

  private

  attr_accessor :commands

  def solve(rope_size:)
    tail_positions = Set.new
    rope = Rope.new(size: rope_size)

    tail_positions << [0, 0]
    commands.each_with_index do |(direction, amount), c|
      amount.times do |i|
        rope.move(direction)
        tail_positions << rope.tail.dup
      end
    end

    tail_positions.size
  end
end

class Rope
  X = 0
  Y = 1

  def initialize(size: 2)
    @knots = Array.new(size) { [0, 0] }
  end

  attr_reader :knots

  def head
    knots.first
  end

  def tail
    knots.last
  end

  def move(direction)
    case direction
    when 'L'
      head[X] -= 1
    when 'R'
      head[X] += 1
    when 'U'
      head[Y] += 1
    when 'D'
      head[Y] -= 1
    end

    (1...knots.size).each do |i|
      adjust_knot(i)
    end

    nil
  end

  def draw
    10.times.reverse_each do |y|
      print "#{y} | "
      10.times do |x|
        i = knots.index([x, y])
        print '.' if i.nil?
        print i
      end
      puts "\n"
    end

    puts("-" * 14)
    print "    "
    puts 10.times.to_a.join
  end

  private

  def adjust_knot(i)
    pull_d(i) if pull_d?(i)
    pull_x(i) if pull_x?(i)
    pull_y(i) if pull_y?(i)
  end

  def pull_x?(i)
    (knots[i - 1][X] - knots[i][X]).abs > 1
  end

  def pull_y?(i)
    (knots[i - 1][Y] - knots[i][Y]).abs > 1
  end

  def pull_d?(i)
    leader = knots[i - 1]
    follower = knots[i]

    return leader[Y] != follower[Y] if pull_x?(i)
    return leader[X] != follower[X] if pull_y?(i)

    false
  end

  def pull_d(i)
    leader = knots[i - 1]
    follower = knots[i]

    follower[X] += leader[X] > follower[X] ? 1 : -1
    follower[Y] += leader[Y] > follower[Y] ? 1 : -1
  end

  def pull_x(i)
    leader = knots[i - 1]
    follower = knots[i]

    follower[X] = leader[X] + (leader[X] > follower[X] ? -1 : 1)
  end

  def pull_y(i)
    leader = knots[i - 1]
    follower = knots[i]

    follower[Y] = leader[Y] + (leader[Y] > follower[Y] ? -1 : 1)
  end
end

PuzzleRunner.run(Day09)
