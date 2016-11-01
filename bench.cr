require "./src/rpn"
require "benchmark"

Benchmark.ips(interactive: STDOUT.tty? && !ENV["TRAVIS"]?) do |b|
  b.report("parse infix") { RPN.from_infix("3 + 4 * 2 / (1 - 5)^2^3") }
  b.report("parse rpn") { RPN.from_string("3 4 2 * 1 5 - 2 3 ^ ^ / +") }
  b.report("execute") { RPN.execute([15, 1, 4, RPN['+'], 3, RPN['^'], 5, RPN['*'], RPN['+'], 3, RPN['-']]) }
  b.report("parse infix + exec") { RPN.execute(RPN.from_infix("3 + 4 * 2 / (1 - 5)^2^3")) }
  b.report("parse rpn + exec") { RPN.execute(RPN.from_string("3 4 2 * 1 5 - 2 3 ^ ^ / +")) }
end
