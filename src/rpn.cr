module RPN
  VERSION = "0.1.0"

  alias Operator = Symbol
  alias Operand = Int32 | Int64 | Float32 | Float64

  def self.execute(rpn) : Float64
    stack = Array(Float64).new

    rpn.each do |item|
      if item.is_a?(Operand)
        stack.push item.to_f64
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
    lhs = stack.pop
    result = yield lhs, rhs
    stack.push result
  end

  def self.from_string(string) : Array(Operator | Operand)
    str = string.chars
    len = str.size

    output = Array(Operator | Operand).new(len)

    i = 0
    while i < len
      if number_start? str, i
        num, i = read_number(str, i)

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

  def self.execute_string(string)
    execute(from_string(string))
  end

  def self.from_infix(string) : Array(Operator | Operand)
    str = string.chars
    len = str.size

    stack = Array(Operator).new(len / 2)
    output = Array(Operator | Operand).new(len)

    i = 0
    while i < len
      if number_start? str, i
        num, i = read_number(str, i)

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

  def self.execute_infix(string)
    execute(from_infix(string))
  end

  private def self.number_start?(str, i)
    # The number either starts with a number or decimal point
    '0' <= str[i] <= '9' || str[i] == '.' || # or starts with a '+' or '-', with a number or decimal point afterwards
 ((str[i] == '-' || str[i] == '+') && i + 1 < str.size && ('0' <= str[i + 1] <= '9' || str[i + 1] == '.'))
  end

  @[AlwaysInline]
  private def self.read_number(str, i)
    len = str.size

    start_index = i
    integer = true
    while (i < len) && ('0' <= str[i] <= '9' || str[i] == '.' || str[i] == '+' || str[i] == '-' || str[i] == 'e')
      integer = false unless '0' <= str[i] <= '9'
      i += 1
    end
    end_index = i - 1

    if integer && (end_index - start_index + 1) < 10
      num = 0
      start_index.upto(end_index) do |i|
        num *= 10
        num += str[i].to_i
      end
    else
      num = str[start_index, end_index - start_index + 1].join.to_f
    end

    {num, end_index}
  end
end
