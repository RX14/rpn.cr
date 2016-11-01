module RPN
  class Lexer
    def initialize(@string : Slice(UInt8), @infix : Bool)
      @accept_number = true
    end

    def next
      str = @string
      raise "next called on finished lexer" unless str.size > 0

      if @accept_number && number_start?(str)
        i = 0
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
          token = num.to_f
        else
          token = String.new(str[start_index, end_index - start_index + 1]).to_f
        end

        str += end_index
        @accept_number = false if @infix
      elsif (token = ASCII_OPERATOR_TABLE[str[0]]) != Operator::Invalid
        @accept_number = true
      else
        raise "invalid operator: #{str[0].chr}"
      end

      str += 1

      # Early return if we're at the end of the string
      return token if str.size == 0

      raise "Expected space after #{str[0].chr}" if !@infix && str[0] != ' '.ord

      while str.size > 0 && str[0] == ' '.ord
        str += 1
      end

      token
    ensure
      @string = str.not_nil!
    end

    def has_next?
      @string.size > 0
    end

    private def number_start?(str)
      # The number either starts with a number or decimal point
      '0'.ord <= str[0] <= '9'.ord || str[0] == '.'.ord || # or starts with a '+' or '-', with a number or decimal point afterwards
 ((str[0] == '-'.ord || str[0] == '+'.ord) && str.size >= 2 && ('0'.ord <= str[1] <= '9'.ord || str[1] == '.'.ord))
    end
  end
end
