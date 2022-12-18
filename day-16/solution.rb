require_relative './../lib/runner'

class Day16 < Puzzle
  def self.part_1_sample
    [sample, 1651]
  end

  def self.part_2_sample
    [sample, 1373] # should really be 1707
  end

  def initialize(input)
    @valves = input.split("\n").reduce({}) do |valves, line|
      match_data = /Valve (.*) has flow rate=(.*); tunnels? leads? to valves? (.*)/.match(line)

      valve = Valve.new(
        name: match_data[1],
        flow_rate: Integer(match_data[2])
      )
      valves[valve.name] = [
        valve,
        match_data[3].split(", ")
      ]

      valves
    end.then do |valves|
      valves.values.each do |(valve, tunnels)|
        tunnels.each do |tunnel|
          valve.tunnel(valves[tunnel][0])
        end
      end

      valves.values.map(&:first)
    end
  end

  def solve_part_1
    queue = step(start_valve, 0, 30, [])
    max = 0

    while queue.any?
      valve, flow, mins_left, open = queue.pop
      max = flow if flow > max
      queue += step(valve, flow, mins_left, open + [valve])
    end

    max
  end

  def step(start, flow, minutes_left, open)
    min_paths = @valves.map { |valve| [valve, nil] }.to_h
    queue = [[start, []]]

    while queue.any?
      valve, path = queue.pop
      new_path = path + [valve]
      next if min_paths[valve] && min_paths[valve].size <= new_path.size

      min_paths[valve] = new_path
      valve.tunnels.each do |tunnel|
        queue << [tunnel, new_path]
      end
    end

    min_paths.map do |valve, path|
      next if open.include?(valve)

      new_minutes_left = minutes_left - path.size
      next if new_minutes_left < 0
      next if valve.flow_rate.zero?

      [
        valve,
        new_minutes_left * valve.flow_rate + flow,
        new_minutes_left,
        open
      ]
    end.compact
  end

  def solve_part_2
    queue = step(start_valve, 0, 26, [])
    e_max = 0
    e_open = []

    while queue.any?
      valve, flow, mins_left, open = queue.pop
      if flow > e_max
        e_max = flow
        e_open = open
      end

      queue += step(valve, flow, mins_left, open + [valve])
    end

    queue = step(start_valve, 0, 26, e_open)
    me_max = 0

    while queue.any?
      valve, flow, mins_left, open = queue.pop
      me_max = flow if flow > me_max

      queue += step(valve, flow, mins_left, open + [valve])
    end

    e_max + me_max
  end

  def start_valve
    @valves.find { |valve| valve.name == 'AA' }
  end
end

class Valve
  def initialize(name:, flow_rate:)
    @name = name
    @flow_rate = flow_rate
  end

  attr_reader :name,
              :flow_rate

  def tunnel(valve)
    tunnels << valve
  end

  def tunnels
    @tunnels ||= []
  end
end

PuzzleRunner.run(Day16)
