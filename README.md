# rpn.cr

A RPN parser and executor written in crystal. It can parse RPN from both infix
and RPN strings, and execute RPN to find a result.

Currently it supports `+` `-` `*` `/` and `^` (exponent) operators.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  rpn:
    github: RX14/rpn.cr
```

## Usage

```crystal
require "rpn"
```

Execute RPN given as an array of numbers and symbols

```cr
RPN.execute([0.5, 2, :"*", 4 :"+"]) # => 5.0
```

Parse RPN from a string containing RPN notation

```cr
RPN.from_string("-.5 2 * 4 +") # => [-0.5, 2.0, :"*", 4.0, :"+"]
```

Parse RPN from a string containing infix notation
```cr
RPN.from_infix("4 + (5 - 3)^4 * 2") # => [4.0, 5.0, 3.0, :"-", 4.0, :"^", 2.0, :"*", :"+"]
```

There are shortcut methods for executing strings directly.
```cr
RPN.execute_string("3 4 +")
# Same as
RPN.execute(RPN.from_string("3 4 +"))
```

```cr
RPN.execute_infix("3 + 4")
# Same as
RPN.execute(RPN.from_infix("3 + 4"))
```

## Development

Hack around, then `crystal spec`.

## Contributing

1. Fork it ( https://github.com/RX14/rpn.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [RX14](https://github.com/RX14) - creator, maintainer
