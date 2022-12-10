require_relative './../lib/runner'

class Day10 < Puzzle
  def self.part_1_sample
    [File.read('sample.txt'), 13140]
  end

  def self.part_2_sample
    # visual so no answer
    [part_1_sample[0], nil]
  end

  def initialize(input)
    @instructions = input.split("\n").map do |instruction|
      case instruction
      when 'noop'
        [:noop]
      when /addx (.*)/
        [:add, :x, Integer($1)]
      end
    end
  end

  def solve_part_1
    x = 1
    samples = []

    Vm.run(instructions) do |vm|
      samples << signal_strength(vm) if sample?(vm.cycle)
    end

    samples.sum
  end

  def solve_part_2
    crt = Crt.new

    Vm.run(instructions) do |vm|
      crt.draw_pixel(vm)
    end

    puts "DRAWING..."
    crt.draw_frame

    nil
  end

  private

  attr_reader :instructions

  def sample?(cycle)
    ((cycle - 20) % 40).zero?
  end

  def signal_strength(vm)
    vm.registers[:x] * vm.cycle
  end
end

class Vm
  def self.run(instructions, &block)
    new(instructions).run(&block)
  end

  def initialize(instructions)
    @instructions = instructions
  end

  def run
    @registers = { pc: 0, x: 1 }
    @cycle = 0

    while instruction = instructions[registers[:pc]]
      send(instruction[0], *instruction.drop(1)) do
        tick!
        yield self
      end

      registers[:pc] += 1
    end
  end

  attr_reader :instructions,
              :registers,
              :cycle

  private

  def tick!
    @cycle += 1
  end

  def noop
    yield
  end

  def add(register, value)
    2.times do
      yield
    end

    registers[register] += value
  end
end

class Crt
  WIDTH = 40
  HEIGHT = 6

  def initialize
    @buffer = Array.new(HEIGHT) do
      Array.new(WIDTH)
    end
  end

  def draw_pixel(vm)
    cycle = vm.cycle - 1
    sprite_x = vm.registers[:x]

    row = cycle / WIDTH
    column = cycle % WIDTH

    buffer[row][column] = lit?(sprite_x, column) ? '#' : '.'
  end

  def draw_frame
    buffer.each do |line|
      puts line.join
    end
  end

  private

  attr_reader :buffer

  def lit?(sprite_x, column)
    ((sprite_x - 1)..(sprite_x + 1)).include?(column)
  end
end

PuzzleRunner.run(Day10)
