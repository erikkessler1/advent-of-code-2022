lines = File.read('./input.txt').split("\n")
sections = lines.map do |line|
  line.split(',').map do |section|
    section.split('-').map(&method(:Integer))
  end.sort do |a, b|
    # makes smaller first
    (a[1] - a[0]) <=> (b[1] - b[0])
  end
end

part_1 = sections.count do |(smaller, bigger)|
  smaller_start, smaller_end = smaller
  bigger_start, bigger_end = bigger
  (smaller_start >= bigger_start) && (smaller_end <= bigger_end)
end
puts part_1

require 'set'
part_2 = sections.count do |(smaller, bigger)|
  smaller_start, smaller_end = smaller
  bigger_start, bigger_end = bigger
  a = Set.new(smaller_start..smaller_end)
  b = Set.new(bigger_start..bigger_end)
  a.intersect?(b)
end
puts part_2
