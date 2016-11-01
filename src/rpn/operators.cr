module RPN
  enum Operator
    # Top byte: Relative precedence
    # Second byte:
    #   AA = Left associative
    #   BA = Right associative
    # Third byte: ascii code
    # Fourth byte: 0xAB if actually an operator, else increasing enum code

    Invalid = 0x00_00_00_00

    LBrace = 0x00_00_28_01
    RBrace = 0x00_00_29_02

    Subtract = 0x02_AA_2D_AB
    Add      = 0x02_AA_2B_AB
    Multiply = 0x03_AA_2A_AB
    Divide   = 0x03_AA_2F_AB
    Modulo   = 0x03_AA_25_AB
    Exponent = 0x04_BA_5E_AB

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

    def operator?
      (value & 0xFF) == 0xAB
    end
  end

  ASCII_OPERATOR_TABLE = begin
    table = Pointer(Operator).malloc(256, Operator::Invalid)

    Operator.values.each do |op|
      table[op.ascii_code] = op if op.ascii_code > 0
    end

    table
  end
end
