require 'set'

lines = File.read('input.txt').split("\n")
parsed = lines.map do |line|
  case line
  when '$ ls'
    [:ls]
  when '$ cd ..'
    [:up]
  when /\$ cd (.*)/
    [:cd, $1]
  when /dir (.*)/
    [:dir, $1]
  when /(\d+) (.*)/
    [:file, $2, Integer($1)]
  else
    raise "Oh no: #{line}"
  end
end

def fn(line, stack)
  "#{stack.join('|')}|#{line[1]}"
end

r = parsed.each_with_object([{}, [], Set.new]) do |line, (sizes, stack, seen)|
  case line[0]
  when :up
    stack.pop
  when :cd
    stack << line[1]
  when :file
    next if seen.include?(fn(line, stack))

    stack.each_with_index do |dir, i|
      ha = stack[0..i].join("|")
      sizes[ha] ||= 0
      sizes[ha] += line[2]
    end
    seen << fn(line, stack)
  end
end

# Part 1
sizes, stack = r
puts sizes.values.select { |size| size <= 100_000 }.sum

# Part 2
free = 70_000_000 - sizes['/']
needed = 30_000_000 - free
puts sizes.values.select { |s| s >= needed }.min
