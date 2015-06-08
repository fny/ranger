require 'minitest_helper'
require 'ranger/interval_like_range'

class TestRefinedRange < Minitest::Test
  using Ranger::IntervalLikeRange

  def test_compare_to_number
    assert_equal -1, (1...2).compare_to_number(0)
    assert_equal 0, (1...2).compare_to_number(1)
    assert_equal 1, (1...2).compare_to_number(2)

    assert_equal -1, (1..2).compare_to_number(0)
    assert_equal 0, (1..2).compare_to_number(1)
    assert_equal 0, (1..2).compare_to_number(2)
    assert_equal 1, (1..2).compare_to_number(3)
  end

  def test_overlaps?
    assert (1...3).overlaps?(2..4)
    refute (1...3).overlaps?(3..4)
  end
end
