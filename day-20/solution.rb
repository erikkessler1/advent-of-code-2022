require_relative './../lib/runner'

class Day20 < Puzzle
  def self.part_1_sample
    [sample, 3]
  end

  def self.part_2_sample
    [sample, 1623178306]
  end

  def initialize(input)
    @encrypted = input.split("\n").map do |line|
      Integer(line)
    end
  end

  def solve_part_1(key: 1, rounds: 1)
    nodes = @encrypted.each_with_index.map do |n, i|
      { i: i, n: n * key, prev: nil, next: nil }
    end
    head = nodes[0]

    # build a doubly linked list
    for i in 0...nodes.size
      nodes[i][:prev] = nodes[i - 1]
      nodes[i][:next] = nodes[(i + 1) % nodes.size]
    end

    for i in 0...(nodes.size * rounds)
      i = i % nodes.size
      node = nodes.find { |n| n[:i] == i }
      next if (node[:n].abs % nodes.size).zero?

      # adjust head if moving head
      head = node[:next] if node == head

      # remove
      old_prev = node[:prev]
      old_next = node[:next]
      old_prev[:next] = old_next
      old_next[:prev] = old_prev

      # move n positions
      insert_at = node
      dir = node[:n].positive? ? :next : :prev
      (node[:n].abs % (nodes.size - 1)).times do
        insert_at = insert_at[dir]
      end
      insert_at = insert_at[:prev] if node[:n].negative?

      # check if moving to head
      head = node if insert_at == head && node[:n].negative?

      # insert
      node[:prev] = insert_at
      node[:next] = insert_at[:next]

      # fixup
      insert_at[:next][:prev] = node
      insert_at[:next] = node
    end

    zero = nodes.find { |n| n[:n] == 0 }
    _, grove = 3_000.times.reduce([zero, []]) do |(c, xs), i|
      xs << c[:next][:n] if ((i + 1) % 1_000).zero?
      [c[:next], xs]
    end

    grove.reduce(:+)
  end

  def solve_part_2
    solve_part_1(key: 811589153, rounds: 10)
  end
end

PuzzleRunner.run(Day20)
