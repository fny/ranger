module Ranger
  # @private
  # Refinements to make ranges more like intervals
  module IntervalLikeRange
    refine Range do
      # @return [-1, 0, 1] -1 if the number is below the range, 0 if the number
      #   is within the range, 1 if the number is above the range; useful for
      #   implementing binary search and comparators
      def compare_to_number(number)
        if cover?(number)
          0
        elsif number < first
          -1
        else number > last
          1
        end
      end

      # @return [Boolean] Whether this range overlaps the `other_range`
      def overlaps?(other_range)
        cover?(other_range.first) || other_range.cover?(first)
      end
    end
  end
end
