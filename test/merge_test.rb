require 'minitest/autorun'
require_relative '../merge'

class MergeTest < Minitest::Test
  def setup
    @spreadsheet_a = Spreadsheet.new(
      [%w[Foo bar baz],
       [1, 2, 3],
       [2, 4, 6],
       [3, 8, 12],
       [4, 16, 24]],
      matcher_i: 1
    )
    @spreadsheet_b = Spreadsheet.new(
      [%w[bish bash bosh Foo],
       ['a', 'b', 'c', 1],
       ['b', 'd', 'f', 2],
       ['g', 'h', 'i', 4],
       ['j', 'k', 'l', 4]],
      matcher_i: 4
    )
  end

  def test_new_headers
    assert_equal @spreadsheet_a.headers, %w[Foo bar baz]
  end
end
