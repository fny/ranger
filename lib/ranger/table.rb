module Ranger
  class Table

    def self.new_open_to_closed
    end

    def self.new_closed_to_open
    end

    def initialize(hash)
      @inner_structure =
        Ranger::Map.new(hash.map { |key, value|
          [make_key(key), Ranger::Map.new(value.map { |k, v| [make_key(k), v] })]
      })
    end

    def [](x_lookup, y_lookup)
      inner_inner_structure = inner_structure[x_lookup]
      inner_inner_structure[y_lookup] if inner_inner_structure
    end

    private

    attr_reader :inner_structure

    def make_key(interval_representation)
      if interval_representation.is_a?(Array)
        Ranger::Interval(*interval_representation)
      else
        interval_representation
      end
    end

  end
end
