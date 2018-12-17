require 'minitest/autorun'
require_relative '../merge'


class MergeTest < Minitest::Test
  def setup
    @a_raw = [%w[Foo bar baz],
              [1, 2, 3],
              [2, 4, 6],
              [3, 8, 12],
              [4, 16, 24]]

    @b_raw = [%w[bish bash bosh Foo],
              ['a', 'b', 'c', 1],
              ['b', 'd', 'f', 2],
              ['g', 'h', 'i', 4],
              ['j', 'k', 'l', 4]]
    @spreadsheet_a = Spreadsheet.new(@a_raw, matcher_i: 0)
    @spreadsheet_b = Spreadsheet.new(@b_raw, matcher_i: 3)
  end

  def test_new_headers
    assert_equal %w[Foo bar baz], @spreadsheet_a.headers
  end

  def test_new_matcher
    assert_equal 'Foo', @spreadsheet_a.matcher
    assert_equal 'Foo', @spreadsheet_b.matcher
  end
end
