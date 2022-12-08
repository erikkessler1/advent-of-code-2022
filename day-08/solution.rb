require 'set'

lines = "30373
25512
65332
33549
35390".split
lines = File.read('./input.txt').split
grid = lines.map { |line| line.split('').map(&method(:Integer)) }

visible = Set.new
for x in 0...grid[0].size
  max = -1
  for y in 0...grid.size
    h = grid[y][x]
    if h > max
      visible << [x, y]
      max = h
    end
  end

  max = -1
  for y in (0...grid.size).reverse_each
    h = grid[y][x]
    if h > max
      visible << [x, y]
      max = h
    end
  end
end

for y in 0...grid.size
  max = -1
  for x in 0...grid[0].size
    h = grid[y][x]
    if h > max
      visible << [x, y]
      max = h
    end
  end

  max = -1
  for x in (0...grid[0].size).reverse_each
    h = grid[y][x]
    if h > max
      visible << [x, y]
      max = h
    end
  end
end

puts "Part 1: #{visible.size}"

computed_grid = Array.new(grid.size) do
  Array.new(grid[0].size) do
    1
  end
end

def apply_dist(value, distances)
  result = (distances[value] || -1) + 1
  for i in 0...distances.size
    if i <= value
      distances[i] = 0
    else
      distances[i] ||= -1
      distances[i] += 1
    end
  end

  result
end

for x in 0...grid[0].size
  distances = Array.new(10)
  for y in 0...grid.size
    h = grid[y][x]
    computed_grid[y][x] *= apply_dist(h, distances)
  end

  distances = Array.new(10)
  for y in (0...grid.size).reverse_each
    h = grid[y][x]
    computed_grid[y][x] *= apply_dist(h, distances)
  end
end

for y in 0...grid.size
  distances = Array.new(10)
  for x in 0...grid[0].size
    h = grid[y][x]
    computed_grid[y][x] *= apply_dist(h, distances)
  end

  distances = Array.new(10)
  for x in (0...grid[0].size).reverse_each
    h = grid[y][x]
    computed_grid[y][x] *= apply_dist(h, distances)
  end
end

puts "Part 2: #{computed_grid.flatten.max}"
