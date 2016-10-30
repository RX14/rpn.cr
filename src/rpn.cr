require "./rpn/*"

module RPN
  VERSION = "0.1.0"

  def self.[](op) : Operator
    case op
    when "+", '+', :"+"
      Operator::Add
    when "-", '-', :"-"
      Operator::Subtract
    when "*", '*', :"*"
      Operator::Multiply
    when "/", '/', :"/"
      Operator::Divide
    when "%", '%', :"%"
      Operator::Modulo
    when "^", '^', :"^"
      Operator::Exponent
    else
      raise "Invalid operator"
    end
  end

  def self.execute(rpn) : Float64
    stack = Array(Float64).new

    rpn.each do |item|
      if item.is_a?(Number)
        stack.push item.to_f
      else
        case item
        when Operator::Add
          two_arg_operator(stack) { |lhs, rhs| lhs + rhs }
        when Operator::Subtract
          two_arg_operator(stack) { |lhs, rhs| lhs - rhs }
        when Operator::Multiply
          two_arg_operator(stack) { |lhs, rhs| lhs * rhs }
        when Operator::Divide
          two_arg_operator(stack) { |lhs, rhs| lhs / rhs }
        when Operator::Exponent
          two_arg_operator(stack) { |lhs, rhs| lhs**rhs }
        end
      end
    end

    raise "#{stack.size} values left on stack" unless stack.size == 1

    stack.pop
  end

  private def self.two_arg_operator(stack)
    raise "Not enough values to execute operator" unless stack.size >= 2

    rhs = stack.pop
    lhs = stack.pop
    result = yield lhs, rhs
    stack.push result
  end

  def self.from_string(string) : Array(Operator | Float64)
    raise "Invalid string: not ascii" unless string.ascii_only?
    str = string.to_slice
    len = str.size

    output = Array(Operator | Float64).new(len)

    i = 0
    while i < len
      if number_start? str, i
        num, i = read_number(str, i)

        # Number token, push to output stack
        # puts "push #{num} to output"
        output << num
      elsif str[i] == ' '.ord
        # Skip whitespace by doing nothing
      else
        op = ASCII_OPERATOR_TABLE[str[i]]
        raise "invalid operator #{str[i].chr}" unless op.valid?
        output << op
      end
      i += 1
    end

    output
  end

  def self.execute_string(string)
    execute(from_string(string))
  end

  def self.from_infix(string) : Array(Operator | Float64)
    raise "Invalid string: not ascii" unless string.ascii_only?
    str = string.to_slice
    len = str.size

    stack = Array(Operator).new(len / 2)
    output = Array(Operator | Float64).new(len)

    i = 0
    while i < len
      if number_start? str, i
        num, i = read_number(str, i)

        # Number token, push to output stack
        # puts "push #{num} to output"
        output << num
      elsif str[i] == ' '.ord
        # Skip whitespace by doing nothing
      elsif str[i] == '('.ord
        # puts "push '(' to stack"
        stack.push Operator::LBrace
      elsif str[i] == ')'.ord
        until stack.last == Operator::LBrace
          # puts "push #{stack.last} to output"
          output << stack.pop
        end
        stack.pop
      else
        o1 = ASCII_OPERATOR_TABLE[str[i]]

        raise "Unsupported operator" unless o1.valid?

        while o2 = stack.last?
          if (o1.left_associative? && o1.precedence <= o2.precedence) ||
             (o1.right_associative? && o1.precedence < o2.precedence)
            # puts "push #{stack.last} to output"
            output << stack.pop
          else
            break
          end
        end

        stack << o1
      end
      i += 1
    end

    until stack.size == 0
      # puts "push #{stack.last} to output"
      output << stack.pop
    end

    output
  end

  def self.execute_infix(string)
    execute(from_infix(string))
  end

  private def self.number_start?(str, i)
    # The number either starts with a number or decimal point
    '0'.ord <= str[i] <= '9'.ord || str[i] == '.'.ord || # or starts with a '+' or '-', with a number or decimal point afterwards
 ((str[i] == '-'.ord || str[i] == '+'.ord) && i + 1 < str.size && ('0'.ord <= str[i + 1] <= '9'.ord || str[i + 1] == '.'.ord))
  end

  @[AlwaysInline]
  private def self.read_number(str, i)
    len = str.size

    start_index = i
    integer = true
    while (i < len) &&
          ('0'.ord <= str[i] <= '9'.ord || str[i] == '.'.ord || str[i] == 'e'.ord ||
          (i == start_index && (str[i] == '+'.ord || str[i] == '-'.ord)))
      integer = false unless '0'.ord <= str[i] <= '9'.ord
      i += 1
    end
    end_index = i - 1

    if integer && (end_index - start_index + 1) < 10
      num = 0
      start_index.upto(end_index) do |i|
        num *= 10
        num += str[i] - '0'.ord
      end
      num = num.to_f
    else
      num = String.new(str[start_index, end_index - start_index + 1]).to_f
    end

    {num, end_index}
  end
end
