require_relative './../lib/runner'

class Day11 < Puzzle
  def self.part_1_sample
    [File.read('sample.txt'), 10605]
  end

  def self.part_2_sample
    [part_1_sample[0], 2713310158]
  end

  def initialize(input)
    @monkeys = input.split(/Monkey .*:\n/).drop(1).map do |monkey_lines|
      lines = monkey_lines.split("\n").map { |line| line.strip }
      MonkeyParser.parse(lines)
    end
  end

  def solve_part_1
    20.times do |round|
      monkeys.each do |monkey|
        monkey.inspect_items(worry_reduction: 3) do |item, target|
          monkeys[target].accept_item(item % divisor)
        end
      end
    end

    monkey_business
  end

  def solve_part_2
    10_000.times do |round|
      monkeys.each do |monkey|
        monkey.inspect_items(worry_reduction: 1) do |item, target|
          monkeys[target].accept_item(item % divisor)
        end
      end
    end

    monkey_business
  end

  private

  attr_reader :monkeys

  # Find the common divisor we can use that will keep the worry levels
  # low but not impact the throws.
  def divisor
    @divisor ||= (1..).find do |i|
      monkeys.all? do |monkey|
        monkey.test?(i)
      end
    end
  end

  def monkey_business
    monkeys.map(&:inspected_count).max(2).reduce(&:*)
  end
end

class MonkeyParser
  def self.parse(lines)
    parser = new(lines)
    parser.parse
  end

  def initialize(lines)
    @lines = lines
  end

  def parse
    items = nil
    operation = nil
    test = nil
    targets = {}

    @lines.each do |line|
      case line
      when /Starting items: (.*)/
        items = $1.split(',').map(&method(:Integer))
      when /Operation: (.*)/
        code = $1
        operation = ->(old) { eval(code) } # yolo
      when /Test: divisible by (.*)/
        value = Integer($1)
        test = ->(item) { (item % value).zero? }
      when /If true: throw to monkey (.*)/
        targets[true] = Integer($1)
      when /If false: throw to monkey (.*)/
        targets[false] = Integer($1)
      end
    end

    Monkey.new(
      items: items,
      operation: operation,
      test: test,
      targets: targets
    )
  end
end

class Monkey
  def initialize(items:, operation:, test:, targets:)
    @items = items
    @operation = operation
    @test = test
    @targets = targets
    @inspected_count = 0
  end

  def inspect_items(worry_reduction:)
    items.each do |item|
      @inspected_count += 1
      new_value = operation.call(item)
      new_value /= worry_reduction

      test_result = test.call(new_value)
      target = targets.fetch(test_result)
      yield(new_value, target)
    end

    @items = []

    nil
  end

  def accept_item(item)
    @items << item
  end

  def test?(item)
    test.call(item)
  end

  attr_reader :inspected_count

  private

  attr_reader :items,
              :operation,
              :test,
              :targets
end

PuzzleRunner.run(Day11)
