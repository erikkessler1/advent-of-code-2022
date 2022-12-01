has = File.read('./input.txt').split("\n")
all, current = has.reduce([[], []]) do |(all, current), line|
  if line == ''
    all << current
    next [all, []]
  end

  current << Integer(line)
  [all, current]
end

all << current

sums = all.map { |cals| cals.sum }

pp sums.max
