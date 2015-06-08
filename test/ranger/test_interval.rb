require 'minitest_helper'

class TestInterval < Minitest::Test

  #
  # Interval Creation
  #

  def test_create_cc_interval
    interval = Ranger::Interval(:closed, 1, 2, :closed)
    assert_instance_of Ranger::CCInterval, interval
    assert_equal [1, 2], interval.endpoints

    assert_equal interval, Ranger::Interval(:c, 1, 2, :c)
  end

  def test_create_co_interval
    interval = Ranger::Interval(:closed, 1, 2, :open)
    assert_instance_of Ranger::COInterval, interval
    assert_equal [1, 2], interval.endpoints

    assert_equal interval, Ranger::Interval(:c, 1, 2, :o)
  end

  def test_create_oc_interval
    interval = Ranger::Interval(:open, 1, 2, :closed)
    assert_instance_of Ranger::OCInterval, interval
    assert_equal [1, 2], interval.endpoints

    assert_equal interval, Ranger::Interval(:o, 1, 2, :c)
  end

  def test_create_oo_interval
    interval = Ranger::Interval(:open, 1, 2, :open)
    assert_instance_of Ranger::OOInterval, interval
    assert_equal [1, 2], interval.endpoints

    assert_equal interval, Ranger::Interval(:o, 1, 2, :o)
  end

  def test_new_delegates_to_creation
    interval = Ranger::Interval.new(:closed, 1, 2, :closed)

    assert_instance_of Ranger::CCInterval, interval
    assert_equal [1, 2], interval.endpoints
  end

  #
  # Sorting
  #

  def test_sorting_of_cc_intervals
    sorted_intervals = [
      Ranger::Interval(:c, 0, 2, :c),
      Ranger::Interval(:c, 2, 4, :c),
      Ranger::Interval(:c, 4, 6, :c)
    ]

    shuffled_intervals = sorted_intervals.shuffle
    assert_equal sorted_intervals, shuffled_intervals.sort
  end

  def test_sorting_of_co_intervals
    sorted_intervals = [
      Ranger::Interval(:c, 0, 2, :o),
      Ranger::Interval(:c, 2, 4, :o),
      Ranger::Interval(:c, 4, 6, :o)
    ]

    shuffled_intervals = sorted_intervals.shuffle
    assert_equal sorted_intervals, shuffled_intervals.sort
  end

  def test_sorting_of_oc_intervals
    sorted_intervals = [
      Ranger::Interval(:o, 0, 2, :c),
      Ranger::Interval(:o, 2, 4, :c),
      Ranger::Interval(:o, 4, 6, :c)
    ]

    shuffled_intervals = sorted_intervals.shuffle
    assert_equal sorted_intervals, shuffled_intervals.sort
  end

  def test_sorting_of_oo_intervals
    sorted_intervals = [
      Ranger::Interval(:o, 0, 2, :o),
      Ranger::Interval(:o, 2, 4, :o),
      Ranger::Interval(:o, 4, 6, :o)
    ]

    shuffled_intervals = sorted_intervals.shuffle
    assert_equal sorted_intervals, shuffled_intervals.sort
  end

  def test_sorting_of_mixed_intervals
    skip "currently unsupported"
    sorted_intervals = [
      Ranger::Interval(:c, 0, 2, :c),
      Ranger::Interval(:c, 0, 2, :o),
      Ranger::Interval(:o, 0, 2, :c),
      Ranger::Interval(:o, 0, 2, :o)
    ]

    shuffled_intervals = sorted_intervals.shuffle
    assert_equal sorted_intervals, shuffled_intervals.sort
  end

  #
  # Other Methods
  #

  def test_compare_to_number
    interval = Ranger::Interval(:c, 1, 2, :o)
    assert_equal -1, interval.compare_to_number(0)
    assert_equal 0, interval.compare_to_number(1)
    assert_equal 1, interval.compare_to_number(2)

    interval = Ranger::Interval(:o, 1, 2, :c)
    assert_equal -1, interval.compare_to_number(1)
    assert_equal 0, interval.compare_to_number(2)
    assert_equal 1, interval.compare_to_number(3)
  end

  def test_shares_open_endpoint?
    interval_o0_1c = Ranger::Interval(:o, 0, 1, :c)
    interval_o1_2c = Ranger::Interval(:o, 1, 2, :o)

    assert interval_o1_2c.shares_open_endpoint?(interval_o0_1c)
    assert interval_o0_1c.shares_open_endpoint?(interval_o1_2c)
  end

  def test_overlaps?
    interval_o0_1c = Ranger::Interval(:o, 0, 1, :c)
    interval_o1_2c = Ranger::Interval(:o, 1, 2, :o)

    refute interval_o0_1c.overlaps?(interval_o1_2c)
    refute interval_o1_2c.overlaps?(interval_o0_1c)

    interval_c1_3o = Ranger::Interval(:c, 1, 3, :o)
    interval_c2_4o = Ranger::Interval(:c, 2, 4, :o)
    interval_c3_4o = Ranger::Interval(:c, 3, 4, :o)

    assert interval_c1_3o.overlaps?(interval_c2_4o)
    assert interval_c2_4o.overlaps?(interval_c1_3o)

    refute interval_c1_3o.overlaps?(interval_c3_4o)
    refute interval_c3_4o.overlaps?(interval_c1_3o)
  end

  def test_to_s
    assert_equal 'Intv[1, 2]', Ranger::Interval(:c, 1, 2, :c).to_s
    assert_equal 'Intv[1, 2)', Ranger::Interval(:c, 1, 2, :o).to_s
    assert_equal 'Intv(1, 2]', Ranger::Interval(:o, 1, 2, :c).to_s
    assert_equal 'Intv(1, 2)', Ranger::Interval(:o, 1, 2, :o).to_s
  end
end
