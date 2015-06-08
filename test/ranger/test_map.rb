require 'minitest_helper'

class TestMap < Minitest::Test

  def test_initiailze_by_range
    skip ""
    map_from_range_hash = Ranger::Map.new(0...1 => 0, 1...2 => 1)
  end

  def test_initialize_by_interval
    map_from_intv_shorthand_hash = Ranger::Map.new(
      [:c, 0, 1, :o] => 0,
      [:c, 1, 2, :o] => 1
    )
    map_from_intv_hash = Ranger::Map.new(
      Ranger::Interval(:c, 0, 1, :o) => 0,
      Ranger::Interval(:c, 1, 2, :o) => 1
    )

    assert_equal map_from_intv_shorthand_hash, map_from_intv_hash
  end

  def test_closed_to_open
    map = Ranger::Map.closed_to_open(
      1 => 1,
      2 => 2,
      3 => nil
    )
    assert_equal 1, map[1]
    assert_equal 1, map[1.5]
    assert_equal 2, map[2]
    assert_equal nil, map[3]
  end

  def test_open_to_closed
    map = Ranger::Map.open_to_closed(
      1 => nil,
      2 => 2,
      3 => 3
    )
    assert_equal nil, map[1]
    assert_equal 2, map[1.5]
    assert_equal 2, map[2]
    assert_equal 3, map[3]
    assert_equal nil, map[3.1]
  end

  def test_lookup_on_ranges
    map = Ranger::Map.new(0...1 => 0, 1...2 => 1)
    assert_equal 0, map[0]
    assert_equal 1, map[1]
    assert_equal nil, map[2]
  end

  def test_lookup_on_co_intervals
    map = Ranger::Map.new(
      Ranger::Interval(:c, 0, 1, :o) => 0,
      Ranger::Interval(:c, 1, 2, :o) => 1
    )
    assert_equal 0, map[0]
    assert_equal 1, map[1]
    assert_equal nil, map[2]
  end

  def test_lookup_on_oc_intervals
    map = Ranger::Map.new(
      Ranger::Interval(:o, 0, 1, :c) => 0,
      Ranger::Interval(:o, 1, 2, :c) => 1
    )
    assert_equal nil, map[0]
    assert_equal 0, map[1]
    assert_equal 1, map[2]
  end

  def test_real_use_case
    map = Ranger::Map.open_to_closed(
      -Float::INFINITY => 0.00,
      -2.50 => 4.15,
      2.25 => 4.00,
      2.00 => 3.75,
      1.75 => 3.25,
      1.50 => 2.50,
      1.25 => 1.50,
      1.00 => 0.75,
      0.75 => 0.00,
      0.50 => 0.00,
      Float::INFINITY => 0.00
    )

    assert_equal 4.15, map[-2.50]
    assert_equal 4.15, map[-2.51]
    assert_equal 4.00, map[-2.25]
    assert_equal 4.00, map[-2.26]
    assert_equal 0, map[1000]
  end

  def test_valid_on_valid_map
    assert Ranger::Map.new(
      Ranger::Interval(:o, 0, 1, :c) => 0,
      Ranger::Interval(:o, 1, 2, :c) => 1
    ).valid?, "no overlaps and in order"
  end

  def test_valid_on_invalid_maps
    refute Ranger::Map.new(
      Ranger::Interval(:o, 0, 1, :c) => 0,
      Ranger::Interval(:c, 1, 2, :c) => 1
    ).valid?, "overlaps at 1"
    refute Ranger::Map.new(
      Ranger::Interval(:o, 1, 2, :c) => 1,
      Ranger::Interval(:o, 0, 1, :c) => 0
    ).valid?, "out of order"
  end
end
