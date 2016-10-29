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
    RPN.execute([
      15, 1, 4, :"+", 3, :"^", 5, :"*", :"+", 3, :"-",
    ]).should eq(15 + (((1 + 4)**3) * 5) - 3)
  end

  it "parses infix" do
    RPN.from_infix("3 + 4 * 2 / (1 - 5)^2^3").should eq([
      3, 4, 2, :"*", 1, 5, :"-", 2, 3, :"^", :"^", :"/", :"+",
    ])
  end
end
