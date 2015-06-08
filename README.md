# DANGER ZONE :construction:

***Note this gem is a work in progress and probably will have its git history rewritten prior to it's v0.1.0 release*** Fork and use at your own peril.

# Ranger :water_buffalo:

Wrangle together numeric ranges and set your boundary conditions.

## Usage

### `Ranger::Interval`

Think `Range` with defined endpoint conditions.

```ruby
require 'ranger/interval'

interval = Ranger::Interval(:open, 1, 2 :closed) # => Intv(1, 2]

interval.cover?(1)   # => false
interval.cover?(1.5) # => true
interval.cover?(2)   # => true

interval.left_open? # => true
interval.left_closed? # => false

shorthand = Ranger::Interval(:o, 1, 2, :c)
interval == shorthand # => true

```

### `Ranger::Map`

#### Instantiation

Note interval/range-value pairs for all maps ***MUST*** have no overlaps and must be listed with left-endpoints in increasing order. See the section below entitled "Validity" for details.

```ruby  
require 'ranger/map'

map = Ranger::Map.new(
  1...2 => :a,
  2...3 => :b,
  3...Float::INFINITY => :c
)

map[1] # => :a
map[1.1] # => :a
map[2] # => :b
map[2.1] # => :b
map[3] # => :c
map[3.1] # => :c
map[Float::INFINITY] # => nil

Ranger::Map.new(
  [:closed, 1, 2, :open ] => :a,
  [:c, 2, 3, :o] => :b
)
```

If you've required `ranger/interval` you define your maps with `Ranger::Interval`. This is required for any intervals that have an open left-endpoint.

```ruby
require 'ranger/interval'
require 'ranger/map'

map = Ranger::Map.new(
  [:open, 1, 2, :closed] => :a,
  [:o, 3, 5, :o] => :b,
  Ranger::Interval(:c, 7, 9, :c) => :c
)


```

#### Shorthand Instantiation

Most times, you'll use the same boundary conditions across all the intervals in your map. Ranger provides an abbreviated notation for the closed-to-open or open-to-closed cases:

##### Closed-to-open Shorthand

```ruby
require 'ranger/map'

Ranger::Map.closed_to_open(
  1 => :a,
  2 => :b,
  3 => nil  # Required, otherwise [2, 3) will be dropped
)

#        -∞     1  2  3     ∞
# (-∞, 1) o-...-o              # => nil, since nothing matches
# [1, 2)        x--o           # => :a
# [2, 3)           x--o        # => :b
# [3, ∞)              x-...-o  # => nil, since nothing matches
```

##### Open-to-closed Shorthand

```ruby
require 'ranger/interval' # Open-to-closed requires Ranger::Interval
require 'ranger/map'

Ranger::Map.new_open_to_closed(
  1 => nil, # Required, otherwise (1, 2] will be dropped
  2 => :a,
  3 => :b
)

#        -∞     1  2  3     ∞
# (-∞, 1] o-...-o              # => nil, since nothing matches
# (1, 2]        o--x           # => :a
# (2, 3]           o--x        # => :b
# (3, ∞)              x-...-o  # => nil, since nothing matches

```


#### Validity

**WARNING: Invalid maps _will_ misbehave.** Interval/range-value pairs provided to a map **MUST** follow these rules to be considered `#valid?` and function properly:

  - There must be no overlaps between the two intervals
  - The left-most endpoint of the intervals must be in increasing order

```ruby
require 'ranger/map'

valid_map = Map.new(
  1...4 => :a,
  4..6 => :b
)
valid_map.valid? # => true


invalid_map = Map.new(
  1..4 => :a,
  4..6 => :b
)
invalid_map.valid? # => false

other_invalid_map = Map.new(
  4...6 => :b,
  1..4 => :a,
)
other_invalid_map.valid? # => false
```

### `Ranger::Table`

```ruby
require 'ranger/table'
```

Docs coming soon.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ranger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ranger

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it (https://github.com/[my-github-username]/ranger/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
