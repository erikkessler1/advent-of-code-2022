lines = File.read('./input.txt').split("\n")

board = lines.take_while do |line|
  line.chomp != ""
end[0...-1].map do |line|
  9.times.map do |i|
    line[i * 4 + 1]
  end
end.reverse.reduce(Array.new(9) { [] }) do |columns, line|
  columns.each_with_index do |column, i|
    column << line[i] if line[i] != " "
  end
  columns
end

moves = lines.drop_while do |line|
  line.chomp != ""
end[1..-1].map do |line|
  match_data = /move (.*) from (.*) to (.*)/.match(line)
  [match_data[1], match_data[2], match_data[3]].map(&method(:Integer))
end

# Part 1
board_p1 = board.map { |column| column.dup }
pp board_p1
moves.each do |count, from, to|
  count.times do
    value = board_p1[from - 1].pop
    board_p1[to - 1] << value
  end
end

puts(board_p1.map { |column| column[-1] }.join)

# Part 2
board_p2 = board.map { |column| column.dup }
moves.each do |count, from, to|
  temp = []

  count.times do
    temp << board_p2[from - 1].pop
  end

  board_p2[to - 1].concat(temp.reverse)
end

puts(board_p2.map { |column| column[-1] }.join)
