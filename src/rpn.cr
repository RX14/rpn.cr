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
        when Operator::Modulo
          two_arg_operator(stack) { |lhs, rhs| lhs % rhs }
        when Operator::Exponent
          two_arg_operator(stack) { |lhs, rhs| lhs**rhs }
        else
          raise "Invalid operator: #{item}"
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

    lexer = Lexer.new(string.to_slice, infix: false)
    output = Array(Operator | Float64).new(string.bytesize)

    while lexer.has_next?
      output << lexer.next
    end

    output
  end

  def self.execute_string(string)
    execute(from_string(string))
  end

  def self.from_infix(string) : Array(Operator | Float64)
    raise "Invalid string: not ascii" unless string.ascii_only?

    lexer = Lexer.new(string.to_slice, infix: true)
    stack = Array(Operator).new(string.bytesize // 2)
    output = Array(Operator | Float64).new(string.bytesize)

    while lexer.has_next?
      case token = lexer.next
      when Float64
        # Number token, push to output stack
        # puts "push #{num} to output"
        output << token
      when Operator::LBrace
        # puts "push '(' to stack"
        stack.push token
      when Operator::RBrace
        until stack.last == Operator::LBrace
          # puts "push #{stack.last} to output"
          output << stack.pop
        end
        stack.pop
      when Operator
        o1 = token
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
end
