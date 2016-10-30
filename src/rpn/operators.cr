module RPN
  enum Operator
    # Top byte: Relative precedence
    # Second byte:
    #   AA = Left associative
    #   BA = Right associative
    # Third byte: ascii code
    # Fourth byte: 0xAB if actually an operator

    Invalid = 0x00
    LBrace  = 0x01 # Used in shunting yard parsing

    Subtract = 0x02AA2DAB
    Add      = 0x02AA2BAB
    Multiply = 0x03AA2AAB
    Divide   = 0x03AA2FAB
    Modulo   = 0x03AA25AB
    Exponent = 0x04BA5EAB

    def precedence
      (value >> (3*8)) & 0xFF
    end

    def associativity
      (value >> (2*8)) & 0xFF
    end

    def left_associative?
      associativity == 0xAA
    end

    def right_associative?
      associativity == 0xBA
    end

    def ascii_code
      (value >> (1*8)) & 0xFF
    end

    def valid?
      (value & 0xFF) == 0xAB
    end
  end

  ASCII_OPERATOR_TABLE = begin
    table = Pointer(Operator).malloc(256)

    Operator.values.each do |op|
      table[op.ascii_code] = op
    end

    table
  end
end
