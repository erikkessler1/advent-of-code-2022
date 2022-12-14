require_relative './../lib/runner'

class Day13 < Puzzle
  def self.part_1_sample
    [sample, 13]
  end

  def self.part_2_sample
    [sample, 140]
  end

  def initialize(input)
    @packets = input.split("\n").map do |packet_line|
      eval(packet_line)
    end.compact
    @pairs = @packets.each_slice(2).each_with_index.map do |packets, i|
      PacketPair.new(i + 1, *packets)
    end
  end

  def solve_part_1
    @pairs.map do |pair|
      pair.ordered? ? pair.index : 0
    end.sum
  end

  def solve_part_2
    keys = [[[2]], [[6]]]
    sorted = @packets.concat(keys).sort do |left, right|
      PacketPair.new(nil, left, right).ordered? ? -1 : 1
    end
    keys.map do |key|
      sorted.index(key) + 1
    end.reduce(:*)
  end
end

class PacketPair
  def initialize(i, left, right)
    @index = i
    @left = left
    @right = right
  end

  def ordered?
    lists_ordered?(@left, @right)
  end

  attr_reader :index

  private

  def lists_ordered?(left_list, right_list)
    zip(left_list, right_list).each do |left, right|
      return true if left.nil?
      return false if right.nil?

      if left.is_a?(Integer) && right.is_a?(Integer)
        next if left == right
        return left < right
      end

      result = lists_ordered?(Array(left), Array(right))
      next if result.nil?

      return result
    end

    nil
  end

  def zip(left, right)
    if left.size >= right.size
      left.zip(right)
    else
      right.zip(left).map(&:reverse)
    end
  end
end

PuzzleRunner.run(Day13)
