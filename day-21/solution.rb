require_relative './../lib/runner'

class Day21 < Puzzle
  def self.part_1_sample
    [sample, 152]
  end

  def self.part_2_sample
    [sample, 301]
  end

  def initialize(input)
    @monkeys = input.split("\n").map do |line|
      line.split(": ")
    end
  end

  def solve_part_1
    monkey_math = MonkeyMath.new(@monkeys)
    monkey_math.root
  end

  def solve_part_2
    MonkeySolver.solve(@monkeys)
  end
end

class MonkeyMath
  def initialize(monkeys)
    monkeys.each do |name, expression|
      define_singleton_method(name) do
        eval(expression)
      end
    end
  end
end

class MonkeySolver
  def self.solve(monkeys)
    new(monkeys).solve
  end

  def initialize(monkeys)
    @monkeys = monkeys
  end

  def solve
    _, left_monkey, right_monkey = parsed_monkeys['root']
    lhs = eval_monkey(left_monkey)
    rhs = eval_monkey(right_monkey)

    solve_system(lhs, rhs)
  end

  private

  def solve_system(lhs, rhs)
    sides = [lhs, rhs]
    solved = sides.find(&method(:solved?))
    to_solve = sides.find(&method(:to_solve?))

    operation, *operands = to_solve
    new_lhs, new_rhs = invert(operation, operands, solved)

    return new_rhs if new_lhs == :humn
    return new_lhs if new_rhs == :humn

    solve_system(new_lhs, new_rhs)
  end

  def solved?(expression)
    expression.is_a?(Integer)
  end

  def to_solve?(expression)
    expression.is_a?(Array)
  end

  def invert(operation, operands, rhs)
    solved = operands.find(&method(:solved?))
    to_solve = operands.find(&method(:to_solve?))

    case operation
    when :+
      [to_solve, rhs - solved]
    when :*
      [to_solve, rhs / solved]
    when :-
      new_rhs = solved?(operands[1]) ? rhs + operands[1] : [:+, rhs, operands[1]]
      [operands[0], new_rhs]
    when :/
      new_rhs = solved?(operands[1]) ? rhs * operands[1] : [:*, rhs, operands[1]]
      [operands[0], new_rhs]
    end
  end

  def eval_monkey(name)
    type, *rest = parsed_monkeys[name]
    return :humn if type == :humn
    return rest[0] if type == :int

    left, right = rest.map { |operand| eval_monkey(operand) }
    computable = solved?(left) && solved?(right)
    return [type, left, right] unless computable

    if type == :+
      left + right
    elsif type == :-
      left - right
    elsif type == :*
      left * right
    elsif type == :/
      left / right
    end
  end

  def parsed_monkeys
    @parsed_monkeys ||= @monkeys.map do |name, expression|
      next ['humn', [:humn]] if name == 'humn'

      if expression.include?('+')
        [name, [:+, *expression.split(' + ')]]
      elsif expression.include?('-')
        [name, [:-, *expression.split(' - ')]]
      elsif expression.include?('*')
        [name, [:*, *expression.split(' * ')]]
      elsif expression.include?('/')
        [name, [:/, *expression.split(' / ')]]
      else
        [name, [:int, Integer(expression)]]
      end
    end.to_h
  end
end

PuzzleRunner.run(Day21)
