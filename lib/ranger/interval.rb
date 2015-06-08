require 'ranger'

module Ranger
  # Creates a new `Ranger::Interval`.
  #
  # @param left_clusivity [:open, :closed, :o, :c]
  # @param left_endpoint [Numeric]
  # @param right_endpoint [Numeric]
  # @param right_clusivity [:open, :closed, :o, :c]
  #
  # @example
  #   # Interval [1, 2)
  #   Ranger::Interval(:closed, 1, 2, :open)
  #   # Short-hand for above
  #   Ranger::Interval(:c, 1, 2, :o)
  # @return [Ranger::Interval]
  def self.Interval(left_clusivity, left_endpoint, right_endpoint, right_clusivity)
    left_inclusive = CLOSED_ENDPOINT_TYPES.include?(left_clusivity)
    right_inclusive = CLOSED_ENDPOINT_TYPES.include?(right_clusivity)

    if left_inclusive && right_inclusive
      CCInterval.new(left_endpoint, right_endpoint)
    elsif left_inclusive && !right_inclusive
      COInterval.new(left_endpoint, right_endpoint)
    elsif !left_inclusive && right_inclusive
      OCInterval.new(left_endpoint, right_endpoint)
    else
      OOInterval.new(left_endpoint, right_endpoint)
    end
  end

  # @abstract Base mixin used by the four interval types, which implement
  #{#cover?}, {#left_closed?}, and {#right_closed?}:
  #
  #  - {Ranger::CCInterval}: [x, y]
  #  - {Ranger::COInterval}: [x, y)
  #  - {Ranger::OCInterval}: (x, y]
  #  - {Ranger::OOInterval}: (x, y)
  module Interval
    # Convenience method for those tempted to call `Interval.new`.
    # @param (see Ranger.Interval)
    # @return [Ranger::Interval]
    def self.new(*args)
      Ranger::Interval(*args)
    end

    # The left endpoint of the interval
    attr_reader :left_endpoint

    alias :first :left_endpoint

    # The right endpoint of the interval
    attr_reader :right_endpoint

    alias :last :right_endpoint

    # @param left_endpoint [Numeric]
    # @param right_endpoint [Numeric]
    def initialize(left_endpoint, right_endpoint)
      @left_endpoint = left_endpoint
      @right_endpoint = right_endpoint
    end

    # @return [Array] the endpoints of the interval
    def endpoints
      [left_endpoint, right_endpoint]
    end

    # @return [Boolean] whether the interval is left-open
    def left_open?
      !left_closed?
    end

    # @return [Boolean] whether the interval is right-open
    def right_open?
      !right_closed?
    end

    # @example
    #   Ranger::Interval(:closed, 1, 2, :open).to_s # => "Intv[1, 2)"
    #
    # @return [String] the interval represented in ISO 31-11 compliant notation
    #   using square brackets and parentheses
    def to_s
      string = 'Intv'
      string << (left_closed? ? '[' : '(')
      string << "#{left_endpoint}, #{right_endpoint}"
      string << (right_closed? ? ']' : ')')
      string
    end

    alias :inspect :to_s

    # Equality: two intervals are equal if they're the same type and have the
    # same endpoints.
    #
    # @param other_interval [Ranger::Interval]
    # @return [Boolean]
    def ==(other_interval)
      self.class == other_interval.class && endpoints == other_interval.endpoints
    end

    # @return [Boolean] Whether this interval overlaps the `other_interval`
    def overlaps?(other_interval)
      return false if shares_open_endpoint?(other_interval)
      cover?(other_interval.first) || other_interval.cover?(first)
    end

    # @api  private
    # @return Boolean whether the other interval shares an open endpoint with
    #   another interval
    def shares_open_endpoint?(other_interval)
      lower, higher = [self, other_interval].sort
      lower.right_endpoint == higher.left_endpoint && !(lower.right_closed? && higher.left_closed?)
    end

    # @api private
    # Comparison: An interval that is "less than" another interval has a higher
    # priority. An interval is "less than" another if its left endpoint comes
    # before the left endpoint of the other interval.
    #
    # Note the behavior of interval comparison is ***only defined for
    # non-overlapping intervals*** for the purpose of this API.
    #
    # @param other_interval [Ranger::Interval]
    #
    # @return [-1, 1] whether this interval is "less than" or "greater than" the
    #   `other_onterval`
    def <=>(other_interval)
      if first < other_interval.first
        -1
      else
        1
      end
    end

    # @api private
    # @return [-1, 0, 1] -1 if the number is below the interval, 0 if the number
    #   is within the interval, 1 if the number is above the interval
    def compare_to_number(number)
      if cover?(number)
        0
      elsif number < first || number == first && left_open?
        -1
      else number > last
        1
      end
    end
  end
end

require 'ranger/intervals/cc_interval'
require 'ranger/intervals/co_interval'
require 'ranger/intervals/oc_interval'
require 'ranger/intervals/oo_interval'
