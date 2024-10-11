# `BigArray`

The `Array` type in Crystal can only contain `Int32::MAX` (`2 ** 32 - 1`) elements because it uses 32-bit integers for indexing. This is useful for everyday operations, but sometimes you need to account for larger collections.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     big_array:
       github: jgaskins/big_array
   ```

2. Run `shards install`

## Usage

```crystal
require "big_array"
```

Many common operations on `Array` are supported, such as `Enumerable` and indexing with `[]` and related methods, but not all operations are supported yet and some methods will return an `Array` rather than a `BigArray`. PRs are welcome.

```crystal
array = BigArray{1, 2, 3}
array.each do |i|
  puts i
end
```

You probably don't want to use this in place of an `Array` all the time, and probably only for larger amounts of data. Some operations that are handy for small arrays, mostly quality-of-life methods like `to_s` and `inspect` to show the contents of the array, are not and will not be implemented on `BigArray` because you almost certainly don't want to accidentally output billions of objects to your terminal. If you need those methods, you probably don't also need to hold billions of values in the same data structure.

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/jgaskins/big_array/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Jamie Gaskins](https://github.com/jgaskins) - creator and maintainer
