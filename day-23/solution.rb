require_relative './../lib/runner'

class Day23 < Puzzle
  def self.part_1_sample
    [sample, 110]
  end

  def self.part_2_sample
    [sample, 20]
  end

  def initialize(input)
    @elves = input.split("\n").each_with_index.flat_map do |line, y|
      line.split("").each_with_index.map do |cell, x|
        next unless cell == '#'

        Elf.new(x, y)
      end.compact
    end
  end

  def solve_part_1
    direction_proposals = DirectionProposals.new
    10.times do
      direction_proposals.next do |directions|
        DiffusionRound.run(@elves, directions)
      end
    end

    xs = @elves.map(&:x)
    ys = @elves.map(&:y)

    ((ys.max - ys.min + 1) * (xs.max - xs.min + 1)) - @elves.size
  end


  def solve_part_2
    direction_proposals = DirectionProposals.new
    (1..).each do |i|
      moved = nil
      direction_proposals.next do |directions|
        moved = DiffusionRound.run(@elves, directions)
      end
      break i if moved == 0
    end
  end
end

class Elf
  def initialize(x, y)
    @x = x
    @y = y
  end

  attr_reader :x,
              :y

  def position
    [x, y]
  end

  def position=((new_x, new_y))
    @x, @y = new_x, new_y
  end
end

class DirectionProposals
  def next
    yield proposals

    proposals.shift.tap do |proposal|
      proposals << proposal
    end
  end

  private

  def proposals
    @proposals ||= [
      [[-1, -1], [0, -1], [1, -1]], # north
      [[-1, 1], [0, 1], [1, 1]], # south
      [[-1, -1], [-1, 0], [-1, 1]], # west
      [[1, -1], [1, 0], [1, 1]], # east
    ]
  end
end

class DiffusionRound
  ADJACENTS = (-1..1).to_a
                .product((-1..1).to_a)
                .reject { |p| p == [0, 0] }

  def self.run(elves, directions)
    new(elves).run(directions)
  end

  def initialize(elves)
    @elves = elves
  end

  def run(directions)
    moving = @elves.select(&method(:any_adjecent?))
    proposals(moving, directions).map do |position, elves|
      next 0 if elves.size > 1

      elves[0].position = position
      1
    end.sum

    # @positions = nil
    # (0..12).each do |y|
    #   (0..14).each do |x|
    #     print elf_at?(x, y) ? '#' : '.'
    #   end
    #   print "\n"
    # end
    # puts "---"
  end

  private

  def any_adjecent?(elf)
    x, y = elf.position
    ADJACENTS.any? do |dx, dy|
      elf_at?(x + dx, y + dy)
    end
  end

  def proposals(moving_elves, directions)
    moving_elves.each_with_object({}) do |elf, proposals|
      x, y = elf.position

      _, move, _ = directions.find do |checks|
        checks.all? do |dx, dy|
          !elf_at?(x + dx, y + dy)
        end
      end
      next if move.nil?

      dx, dy = move
      new_position = [x + dx, y + dy]
      proposals[new_position] ||= []
      proposals[new_position] << elf
    end
  end

  def elf_at?(x, y)
    positions.key?([x, y])
  end

  def positions
    @positions ||= @elves.each_with_object({}) do |elf, positions|
      positions[elf.position] = elf
    end
  end
end

PuzzleRunner.run(Day23)
