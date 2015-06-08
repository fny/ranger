require 'ranger/interval_like_range'

module Ranger
  # A {Ranger::Map} is a dictionary-like collection of intervalsranges/
  class Map
    using Ranger::IntervalLikeRange

    # Shorthand for generating closed-to-open interval maps.
    #
    # @example Right-bounded
    #   Ranger::Map.closed_to_open(
    #     1 => :a,
    #     2 => :b,
    #     3 => nil  # Required, otherwise [2, 3) will be dropped
    #   )
    #
    #   #        -∞     1  2  3     ∞
    #   # (-∞, 1) o-...-o              # => nil, since nothing matches
    #   # [1, 2)        x--o           # => :a
    #   # [2, 3)           x--o        # => :b
    #   # [3, ∞)              x-...-o  # => nil, since nothing matches
    #
    # @example Right-unbounded
    #   Ranger::Map.closed_to_open(
    #     1 => :a,
    #     2 => :b,
    #     3 => :c,
    #     Float::INFINITY => nil  # Required, otherwise [3, ∞) will be dropped
    #   )
    #
    #   #        -∞     1  2  3     ∞
    #   # (-∞, 1) o-...-o              # => nil, since nothing matches
    #   # [1, 2)        x--o           # => 'a'
    #   # [2, 3)           x--o        # => 'b'
    #   # [3, ∞)              x-...-o  # => 'c'
    def self.closed_to_open(abbr_mapping)
      mapping = abbr_mapping.each_cons(2).map { |pair, next_pair|
        [ pair[0]...next_pair[0], pair[1] ]
      }
      new(mapping)
    end

    # Shorthand for generating open-to-closed interval maps. Note this requires
    # {Ranger::Interval}, so be sure to `require 'ranger/interval'` first.
    #
    # @example Left-bounded
    #
    #   Ranger::Map.new_open_to_closed(
    #     1 => nil, # Required, otherwise (1, 2] will be dropped
    #     2 => :a,
    #     3 => :b
    #   )
    #
    #   #        -∞     1  2  3     ∞
    #   # (-∞, 1] o-...-o              # => nil, since nothing matches
    #   # (1, 2]        o--x           # => :a
    #   # (2, 3]           o--x        # => :b
    #   # (3, ∞)              x-...-o  # => nil, since nothing matches
    #
    # @example Left-unbounded
    #
    #   Ranger::Map.new_open_to_closed(
    #     -Float::INFINITY => nil,
    #     1 => :a,
    #     2 => :b,
    #     3 => :c
    #   )
    #
    #   #        -∞     1  2  3     ∞
    #   # (-∞, 1] o-...-x              # => :a
    #   # (1, 2]        o--x           # => :b
    #   # (2, 3]           o--x        # => :c
    #   # (3, ∞)              o-...-x  # => nil, since nothing matches
    def self.open_to_closed(abbr_mapping)
      mapping = abbr_mapping.each_cons(2).map { |pair, next_pair|
        [
          Ranger::Interval(:opened, pair[0], next_pair[0], :closed),
          next_pair[1]
        ]
      }
      new(mapping)
    rescue NoMethodError => e
      if e.message.include?('Interval')
        raise NoMethodError, "You'll need to require 'ranger/interval' to use " \
          "Ranger::Map.new_oc"
      else
        raise e
      end
    end

    def self.shorthand(left, right, data)
      left_inclusive = CLOSED_ENDPOINT_TYPES.include?(left_clusivity)
      right_inclusive = CLOSED_ENDPOINT_TYPES.include?(right_clusivity)

      if left_inclusive && !right_inclusive
        closed_to_open(data)

      elsif !left_inclusive && right_inclusive
        open_to_closed(data)
      else
        raise ArgumentError, "Unsupported endpoint combination: #{left} #{right}"
      end
    end

    # @param pairs [{Range => Object}, {Ranger::Interval => Object}]
    #
    # @example Range-based initialization
    #
    #   Ranger::Map.new(
    #     0...1 => 0,
    #     1...2 => 1
    #   )
    #
    # @example Shorthand initialization
    #
    #   Ranger::Map.new(
    #     [:open, 0, 1 :closed] => 0,
    #     [:open, 1, 2 :closed] => 1
    #   )
    def initialize(pairs)
      mapping = []
      pairs.each do |key, value|
        mapping << [
          (key.is_a?(Array) ? Ranger::Interval(*key) : key), value
        ]
      end
      @mapping = mapping
    end

    # Two maps are considered equivalent when their internal mappings and their
    # orderings are equivalent.
    #
    # @return [Boolean] whether the two maps are equal
    def ==(other_map)
      mapping == other_map.mapping
    end

    # Retrieves the value object corresponding to the key object. Only
    # guaranteed to work if the map is {#valid?}
    #
    #  @param key [Object] value to lookup
    #
    # @return [Object or nil] value from matching range/interval; `nil` if no
    #   matching range/interval is found
    def [](key)
      result = mapping.bsearch { |mapping|
        interval, interval_value = mapping
        interval.compare_to_number(key)
      }
      result[1] if result
    end

    # Maps are valid where the map they represent a proper function (i.e. no
    # overlapping keys) and when the keys are sorted. Otherwise funky things
    # might happen.
    #
    # @return [Boolean] whether the the map is safe to operate on
    #
    # related to exactly one
    #   output (i.e. no keys overlap)
    def valid?
      !has_overlaps?  && left_endpoints_sorted?
    end

    protected

    # Array of [Range, Object] or [Ranger::Interval, Object] pairs to search
    # when determining values
    attr_reader :mapping

    private

    def left_endpoints_sorted?
      mapping.map(&:first).map(&:first).each_cons(2).all? { |x, y| x <= y }
    end

    def overlaps
      overlaps = []
      mapping.combination(2).each do |pair, other_pair|
        interval = pair[0]
        other_interval = other_pair[0]
        overlaps << [pair, other_pair] if interval.overlaps?(other_interval)
      end
      overlaps
    end

    def has_overlaps?
      overlaps.any?
    end
  end
end


