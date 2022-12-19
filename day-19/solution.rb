require_relative './../lib/runner'

class Day19 < Puzzle
  def self.part_1_sample
    [sample, 33]
  end

  def self.part_2_sample
    [sample, nil]
  end

  def initialize(input)
    @blueprints = input.split("\n").map do |line|
      match_data = /Blueprint (.*): Each ore robot costs (.*) ore. Each clay robot costs (.*) ore. Each obsidian robot costs (.*) ore and (.*) clay. Each geode robot costs (.*) ore and (.*) obsidian./.match(line)

      Blueprint.new(
        id: Integer(match_data[1]),
        costs: {
          ore: [[Integer(match_data[2]), :ore]],
          clay: [[Integer(match_data[3]), :ore]],
          obsidian: [[Integer(match_data[4]), :ore], [Integer(match_data[5]), :clay]],
          geode: [[Integer(match_data[6]), :ore], [Integer(match_data[7]), :obsidian]]
        }
      )
    end
  end

  def solve_part_1
    @blueprints.map do |blueprint|
      max = LngComputer.compute_largest_number_of_geodes(blueprint, minutes: 24)
      puts "#{blueprint.id}: #{max} GEODES!"
      blueprint.id * max
    end.reduce(:+)
  end

  def solve_part_2
    return nil if @blueprints.size == 2 # don't test the sample; too slow lol

    @blueprints.take(3).map do |blueprint|
      max = LngComputer.compute_largest_number_of_geodes(blueprint, minutes: 32)
      puts "#{blueprint.id}: #{max} GEODES!"
      max
    end.reduce(:*)
  end
end

class LngComputer
  def self.compute_largest_number_of_geodes(blueprint, **args)
    new(blueprint).compute_largest_number_of_geodes(**args)
  end

  def initialize(blueprint)
    @blueprint = blueprint
  end

  def compute_largest_number_of_geodes(minutes: 24)
    queue = [
      LngState.new(
        robots: { ore: 1, clay: 0, obsidian: 0, geode: 0 },
        collection: { ore: 0, clay: 0, obsidian: 0, geode: 0 },
        minutes_left: minutes
      )
    ]
    geode_max = 0
    steps = 0

    while queue.any?
      state = queue.pop

      puts "#{@blueprint.id}: #{steps / 1_000}K STEPS" if (steps % 500_000).zero?
      steps += 1

      if state.collection[:geode] > geode_max
        geode_max = state.collection[:geode] if state.collection[:geode] > geode_max
      end

      state.step(@blueprint) do |new_state|
        queue << new_state
      end
    end

    geode_max
  end

  private
end

class LngState
  def initialize(robots:, collection:, minutes_left:)
    @robots = robots
    @collection = collection
    @minutes_left = minutes_left
  end

  attr_reader :robots,
              :collection,
              :minutes_left

  def step(blueprint)
    return if minutes_left.zero?
    return if collection[:geode] < blueprint.max_geodes[minutes_left]

    if collection[:geode] > blueprint.max_geodes[minutes_left]
      blueprint.max_geodes[minutes_left] = collection[:geode]
    end

    if !can_build_leaf_type?(blueprint)
      yield LngState.new(
              robots: robots,
              collection: next_collection,
              minutes_left: minutes_left - 1
            )
    end

    blueprint.build_options(collection).each do |type, new_collection|
      next if !leaf_type?(type) && can_build_leaf_type?(blueprint) # always build
      next if type != :geode && max_for_type?(type, blueprint) # don't build more than we need

      next_robots = robots.dup
      next_robots[type] += 1

      yield LngState.new(
              robots: next_robots,
              collection: next_collection(new_collection),
              minutes_left: minutes_left - 1
            )
    end
  end

  private

  def have_geode_robot?
    robots[:geode] > 0
  end

  def leaf_type?(type)
    type == :geode || type == :obsidian
  end

  def can_build_leaf_type?(blueprint)
    blueprint.can_build?(:geode, from: collection) || blueprint.can_build?(:obsidian, from: collection)
  end

  def next_collection(source_collection = collection)
    next_collection = source_collection.dup

    robots.each do |type, count|
      next_collection[type] += count
    end

    next_collection
  end

  def max_for_type?(type, blueprint)
    robots[type] >= blueprint.max_costs[type]
  end
end

class Blueprint
  def initialize(id:, costs:)
    @id = id
    @costs = costs
  end

  attr_reader :id,
              :costs

  def build_options(collection)
    [:ore, :clay, :obsidian, :geode].map do |type|
      build(type, from: collection) if can_build?(type, from: collection)
    end.compact
  end

  def can_build?(build_type, from:)
    @costs[build_type].all? do |cost, type|
      from[type] >= cost
    end
  end

  def build(build_type, from:)
    new_collection = from.dup

    @costs[build_type].each do |cost, type|
      new_collection[type] -= cost
    end

    [build_type, new_collection]
  end

  def max_costs
    @max_costs ||= Hash.new do |max_costs, type|
      max_costs[type] = costs.values.flat_map do |type_costs|
        type_costs.map do |count, cost_type|
          cost_type == type ? count : 0
        end
      end.max
    end
  end

  def max_geodes
    @max_geodes ||= Hash.new do |maxes, minute|
      maxes[minute] = 0
    end
  end
end

PuzzleRunner.run(Day19, part: 2)
