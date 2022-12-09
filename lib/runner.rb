require 'set'

class Puzzle
  def self.from_input
    new(File.read('input.txt'))
  end
end

class PuzzleRunner
  def self.run(day, part: nil)
    new(day).run(part)
  end

  def initialize(day)
    @day = day
  end

  def run(part)
    if part.nil? || part == 1
      puts "PART 1:"
      test_sample(part: 1)
      solve(part: 1)
    end

    puts("-" * 34) if part.nil?

    if part.nil? || part == 2
      puts "PART 2:"
      test_sample(part: 2)
      solve(part: 2)
    end
  end

  private

  attr_reader :day

  def test_sample(part:)
    print "  TESTING SAMPLE... "

    input, answer = day.send("part_#{part}_sample")
    puzzle = day.new(input)
    result = puzzle.send("solve_part_#{part}")

    if result != answer
      puts "FAILED!"
      puts "GOT: #{result}"
      puts "EXPECTED: #{answer}"
      exit(1)
    end

    puts "PASSED!"
  end

  def solve(part:)
    print "  SOLVING PART #{part}... "

    puzzle = day.from_input
    result = puzzle.send("solve_part_#{part}")

    puts result
  end
end
