require 'minitest/autorun'
require_relative '../merge'


class MergeTest < Minitest::Test
  def setup
    @a_raw = [%w[Foo bar baz],
              %w[1   2   3],
              %w[2   4   6],
              %w[3   8   12],
              %w[4   16  24]]

    @b_raw = [%w[bish bash bosh Foo],
              %w[a    b    c    1],
              %w[b    d    f    2],
              %w[g    h    i    4],
              %w[j    k    l    4]]

    @spreadsheet_a = Spreadsheet.new(@a_raw, matcher_i: 0)
    @spreadsheet_b = Spreadsheet.new(@b_raw, matcher_i: 3)
    @combined      = Spreadsheet.combine([@spreadsheet_a, @spreadsheet_b])
  end

  def test_pick_matcher_w_int
    a = Spreadsheet.new(@a_raw)
    a.pick_matcher(0)
    assert_equal 'Foo', a.matcher
  end

  def test_new_headers
    assert_equal %w[Foo bar baz], @spreadsheet_a.headers
  end

  def test_new_matcher
    assert_equal 'Foo', @spreadsheet_a.matcher
    assert_equal 'Foo', @spreadsheet_b.matcher
  end

  def test_from_combined_has_all_values
    all_values   = [@a_raw, @b_raw].flatten.uniq
    all_combined = [@combined.rows, @combined.headers].flatten.uniq
    diff         = all_values - all_combined

    assert_equal [], diff
  end

  def test_combined_has_right_n_of_rows
    exp_rows = [@spreadsheet_a, @spreadsheet_b].map(&:match_data)
      .map { |d| d.reduce(Hash.new(0)) { |f, e| f[e] += 1; f } }
      .reduce do |a, b|
        a.merge(b) { |_, va, vb| [va, vb].max }.values.reduce(&:+)
      end
    assert_equal exp_rows, @combined.rows.length
  end

  def test_combined_has_right_n_of_headers
    exp_headers = @a_raw[0].length + @b_raw[0].length
    assert_equal exp_headers, @combined.headers.length
  end
end
