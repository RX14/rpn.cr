module RPN
  VERSION = "0.1.0"

  alias Operator = Symbol
  alias Operand = Int32 | Int64 | Float32 | Float64

  def self.execute(rpn)
    stack = Array(Operator | Operand).new

    rpn.each do |item|
      if item.is_a?(Operand)
        stack.push item
      else
        case item
        when :"+"
          two_arg_operator(stack) { |lhs, rhs| lhs + rhs }
        when :"-"
          two_arg_operator(stack) { |lhs, rhs| lhs - rhs }
        when :"*"
          two_arg_operator(stack) { |lhs, rhs| lhs * rhs }
        when :"/"
          two_arg_operator(stack) { |lhs, rhs| lhs / rhs }
        when :"^"
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
    raise "Expected operand but was operator" unless rhs.is_a?(Operand)

    lhs = stack.pop
    raise "Expected operand but was operator" unless lhs.is_a?(Operand)

    result = yield lhs, rhs
    stack.push result
  end

  def self.from_string(string)
    str = string.chars
    len = str.size

    output = Array(Operator | Operand).new(len)

    i = 0
    while i < len
      if '0' <= str[i] <= '9'
        num = str[i].to_i.to_i
        while (i + 1 < len) && '0' <= str[i + 1] <= '9'
          num *= 10
          num += str[i + 1].to_i
          i += 1
        end

        # Number token, push to output stack
        # puts "push #{num} to output"
        output << num
      elsif str[i] == ' '
        # Skip whitespace by doing nothing
      else
        case str[i]
        when '+'
          output << :"+"
        when '-'
          output << :"-"
        when '*'
          output << :"*"
        when '/'
          output << :"/"
        when '^'
          output << :"^"
        end
      end
      i += 1
    end

    output
  end

  def self.from_infix(string)
    str = string.chars
    len = str.size

    stack = Array(Operator).new(len / 2)
    output = Array(Operator | Operand).new(len)

    i = 0
    while i < len
      if '0' <= str[i] <= '9'
        num = str[i].to_i.to_i
        while (i + 1 < len) && '0' <= str[i + 1] <= '9'
          num *= 10
          num += str[i + 1].to_i
          i += 1
        end

        # Number token, push to output stack
        # puts "push #{num} to output"
        output << num
      elsif str[i] == ' '
        # Skip whitespace by doing nothing
      else
        case str[i]
        when '+'
          while o2 = stack.last?
            # '+' is left-associative, so we want to pop while the precedence
            # is greater than or equal to '+'
            if {:"+", :"-", :"*", :"/", :"^"}.includes? o2
              # puts "push #{stack.last} to output"
              output << stack.pop
            else
              break
            end
          end
          # puts "push '+' to stack"
          stack.push :"+"
        when '-'
          while o2 = stack.last?
            # '-' is left-associative, so we want to pop while the precedence
            # is greater than or equal to '-'
            if {:"+", :"-", :"*", :"/", :"^"}.includes? o2
              # puts "push #{stack.last} to output"
              output << stack.pop
            else
              break
            end
          end
          # puts "push '-' to stack"
          stack.push :"-"
        when '*'
          while o2 = stack.last?
            # '*' is left-associative, so we want to pop while the precedence
            # is greater than or equal to '*'
            if {:"*", :"/", :"^"}.includes? o2
              # puts "push #{stack.last} to output"
              output << stack.pop
            else
              break
            end
          end
          # puts "push '*' to stack"
          stack.push :"*"
        when '/'
          while o2 = stack.last?
            # '/' is left-associative, so we want to pop while the precedence
            # is greater than or equal to '/'
            if {:"*", :"/", :"^"}.includes? o2
              # puts "push #{stack.last} to output"
              output << stack.pop
            else
              break
            end
          end
          # puts "push '/' to stack"
          stack.push :"/"
        when '^'
          while o2 = stack.last?
            # '^' is right-associative, so we want to pop while the precedence
            # is greater than '^'
            if false # Nothing greater than '^'
              # puts "push #{stack.last} to output"
              output << stack.pop
            else
              break
            end
          end
          # puts "push '^' to stack"
          stack.push :"^"
        when '('
          # puts "push '(' to stack"
          stack.push :"("
        when ')'
          until stack.last == :"("
            # puts "push #{stack.last} to output"
            output << stack.pop
          end
          stack.pop
        else
          raise "fucking invalid"
        end
      end
      i += 1
    end

    until stack.size == 0
      output << stack.pop
    end

    output
  end
end
