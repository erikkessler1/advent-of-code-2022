require_relative './../lib/runner'

class Day24 < Puzzle
  def self.part_1_sample
    [sample, 18]
  end

  def self.part_2_sample
    [sample, 54]
  end

  def initialize(input)
    lines = input.split("\n")

    @valley = Valley.new(width: lines[0].size, height: lines.size)
    initial_item_positions = lines.each_with_index.flat_map do |line, y|
      line.split("").each_with_index.map do |cell, x|
        position = [x, y]
        type = case cell
               when '#'
                 Wall.new(@valley)
               when 'E'
                 @expedition = Expedition.new(@valley)
                 @start_position = [x, y]
                 next nil
               when 'G'
                 @goal_position = [x, y]
                 next nil
               when '.'
                 next nil
               when /[<>v^]/
                 Blizzard.new(@valley, cell)
               end
        [position, type]
      end
    end.compact.to_h

    # the state is the same evey lcm minutes
    @lcm = (1..).find do |i|
      (i % @valley.width).zero? && (i % @valley.height).zero?
    end

    # cache the state by minute
    @item_positions_by_minute = Hash.new do |hash, minute|
      minute = minute % @lcm
      next hash[minute] = initial_item_positions if minute.zero?

      hash[minute] = move(hash[minute - 1])
    end
  end

  def solve_part_1(start_position: @start_position, start_minute: 0)
    queue = [[start_minute, start_position]]
    min_minute = nil
    seen = Set.new
    i = 0

    while queue.any?
      i += 1
      minute, position = queue.pop

      # for progress
      if (i % 10_000).zero?
        puts i
        puts min_minute
        puts queue.size
      end

      next if seen.include?([minute % @lcm, position])
      next if min_minute && minute >= min_minute

      seen << [minute, position]

      if goal?(position)
        min_minute = minute if min_minute.nil? || minute < min_minute
        next
      end

      new_minute = minute + 1
      new_item_positions = @item_positions_by_minute[new_minute]

      @expedition.options(
        from: position,
        items: new_item_positions,
        avoid: minute > start_minute + 10 ? start_position : nil, # don't sit at the start
        reverse: start_position != @start_position
      ).each do |new_position|
        queue << [new_minute, new_position]
      end
    end

    min_minute
  end


  def solve_part_2
    leg_1 = solve_part_1
    puts "LEG 1: #{leg_1}"

    old_goal = @goal_position
    @goal_position = @start_position
    leg_2 = solve_part_1(start_position: old_goal, start_minute: leg_1)
    puts "LEG 2: #{leg_2}"

    @goal_position = old_goal
    leg_3 = solve_part_1(start_position: @start_position, start_minute: leg_2)
    puts "LEG 3: #{leg_3}"

    leg_3
  end

  def goal?(expedition_position)
    expedition_position == @goal_position
  end

  def move(item_positions)
    item_positions.flat_map do |position, items|
      Array(items).map do |item|
        new_position = item.move(from: position, items: item_positions)
        next if new_position.nil?

        [new_position, item]
      end.compact
    end.reduce({}) do |new_items, (position, item)|
      if new_items.key?(position)
        new_items[position] = Array(new_items[position]) + [item]
      else
        new_items[position] = item
      end

      new_items
    end
  end
end

class Valley
  def initialize(width: , height:)
    @width = width
    @height = height
  end

  attr_reader :width,
              :height
end

class ValleyItem
  def initialize(valley)
    @valley = valley
  end

  def move(from:, items:)
    from
  end

  private

  attr_reader :valley
end

class Wall < ValleyItem
  def to_s
    '#'
  end
end

class Expedition < ValleyItem
  def options(from:, items:, avoid:, reverse:)
    x, y = from
    [
      [0, 0], # wait
      [0, -1],
      [1, 0],
      [0, 1],
      [-1, 0]
    ].map do |dx, dy|
      position = [x + dx, y + dy]
      next if (y + dy) < 0 || (y + dy) >= valley.height
      next if position == avoid
      next if !items[position].nil?

      position
    end.compact.sort do |a, b|
      # try to move towards the goal (a corner)
      reverse ? b.sum <=> a.sum : a.sum <=> b.sum
    end
  end

  def to_s
    'E'
  end
end

class Blizzard < ValleyItem
  def initialize(valley, direction)
    super(valley)
    @direction = direction
  end

  def move(from:, items:)
    x, y = from
    case @direction
    when '<'
      [x - 1, y]
    when '>'
      [x + 1, y]
    when '^'
      [x, y - 1]
    when 'v'
      [x, y + 1]
    end.then do |position|
      wrap(position, items: items)
    end
  end

  def to_s
    @direction
  end

  private

  def wrap((x, y), items:)
    return [x, y] unless items[[x, y]].is_a?(Wall)

    case @direction
    when '<'
      [valley.width - 2, y]
    when '>'
      [1, y]
    when '^'
      [x, valley.height - 2]
    when 'v'
      [x, 1]
    end
  end
end

PuzzleRunner.run(Day24)
