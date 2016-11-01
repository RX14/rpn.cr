require "./spec_helper"
require "yaml"

describe RPN do
  describe "VERSION" do
    it "matches shards.yml" do
      version = YAML.parse(File.read(File.join(__DIR__, "..", "shard.yml")))["version"].as_s
      version.should eq(RPN::VERSION)
    end
  end

  it "executes RPN" do
    RPN.execute([1, 2, RPN['+']]).should eq(3.0)
    RPN.execute([1, 2, RPN['-']]).should eq(-1.0)
    RPN.execute([1, 2, RPN['*']]).should eq(2.0)
    RPN.execute([1, 2, RPN['/']]).should eq(0.5)
    RPN.execute([14, 5, RPN['%']]).should eq(4.0)
    RPN.execute([2, 10, RPN['^']]).should eq(1024.0)

    RPN.execute([
      15, 1, 4, RPN['+'], 3, RPN['^'], 5, RPN['*'], RPN['+'], 3, RPN['-'],
    ]).should eq(15 + (((1 + 4)**3) * 5) - 3)
  end

  it "parses RPN strings" do
    RPN.from_string("1 2 +").should eq([1.0, 2.0, RPN['+']])
    RPN.from_string("1234567890 2 *").should eq([1234567890.0, 2.0, RPN['*']])
    RPN.from_string("14 5 %").should eq([14, 5, RPN['%']])
    RPN.from_string("3.4 -44.23e5 2 * 1 5 - 2 3 ^ ^ / +").should eq([
      3.4, -44.23e5, 2, RPN['*'], 1, 5, RPN['-'], 2, 3, RPN['^'], RPN['^'], RPN['/'], RPN['+'],
    ])
  end

  it "executes RPN strings" do
    RPN.execute_string("3 4 2 * 1 5 - 2 3 ^ ^ / +").should be_close(3.00012207031, 1e-10)
  end

  it "parses infix" do
    RPN.from_infix("1+2").should eq([1.0, 2.0, RPN['+']])
    RPN.from_infix("1234567890*2").should eq([1234567890.0, 2.0, RPN['*']])
    RPN.from_infix("14%5").should eq([14, 5, RPN['%']])
    RPN.from_infix("3 + 4 * 2 / (1 - 5)^2^3").should eq([
      3, 4, 2, RPN['*'], 1, 5, RPN['-'], 2, 3, RPN['^'], RPN['^'], RPN['/'], RPN['+'],
    ])
  end

  it "executes infix" do
    RPN.execute_infix("3 + 4 * 2 / (1 - 5)^2^3").should be_close(3.00012207031, 1e-10)
  end
end
