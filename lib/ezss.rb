require 'csv'

class Spreadsheet
  class << self
    def from_file(file, matcher_i: nil)
      new(CSV.read(file), name: file, matcher_i: matcher_i)
    end

    # NOTE: doesn't work with > 2 spreadsheets?
    def combine(spreadsheets)
      matchers = spreadsheets.map(&:match_data).flatten.uniq

      matches = merge_search_results(
        spreadsheets.map do |ss|
          ss.search_matchers(matchers, empty_offset: true) 
        end
      )

      rows = matches.values
                    .flat_map { |ms| ms.shift.product(*ms) }
                    .map(&:flatten)
      new([spreadsheets.flat_map(&:headers), *rows], name: name)
    end

    private

    # Takes an array of hashes and merges values like this:
    # { a: 1, b: [1] } -> { a: 2, b: [2] } -> { a: [[1], [2]], b: [[[1]], [[2]]] }
    # NOTE: Might be worth to extract a to a HOF and have a better named
    # function for #combine and #merge_search_results
    def merge_search_results(hs)
      hs.reduce do |ha, hb|
        ha.merge(hb) { |_, va, vb| [va] << vb }
      end
    end
  end

  attr_reader :name, :headers, :rows, :matcher_i

  def initialize(rows, name: nil, matcher_i: nil)
    rows       = rows.clone # don't mutate original rows
    @name      = name
    @headers   = rows.shift
    @rows      = rows
    @matcher_i = matcher_i
  end

	# Useful for representing empty matches without screwing up csv formatting in #write
  def offset
    Array.new(headers.length, '')
  end

  def matcher
    @matcher_i && headers[@matcher_i]
  end

	# Search spreadsheet for rows with matcher == to arg
	# :empty_offset : Return #offset value instead of empty array when no
	# matching rows (DEFAULT: FALSE)
  def matcher_search(m, empty_offset: false)
    r = rows.select { |r| r[matcher_i] == m }
    if empty_offset
      r.empty? ? [offset] : r
    else
      r
    end
  end

  def search_matchers(ms, empty_offset: false)
    ms.map { |m| [m, matcher_search(m, empty_offset: empty_offset)] }.to_h
  end

	# Return all matchers
  def match_data
    rows.map { |row| row[matcher_i] }
  end

	# Set matcher_i either through arg or block which yields headers
  def pick_matcher(ind = nil)
    @matcher_i = ind || yield(headers)
  end

	# yields row and spreadsheet and
  def map!
    @rows = @rows.map { |row| yield row, self }
  end

	# Shortcut to pick matcher_i interactively from STDIN
  def pick_matcher_from_prompt
    pick_matcher do |headers|
      puts "Which header do you want to match#{" for #{name}" if name}?"
      headers.each_with_index { |h, i| puts "#{i}) #{h}" }

      print('Your choice?: '); Integer(STDIN.gets.chomp)
    end
  end

	# Writes headers and rows to file
	# No way to write to object only yet as I don't think the csv lib can do that :(
  def write(filename)
    CSV.open(filename, 'w', force_quotes: true) do |csvf|
      csvf << headers
      rows.each { |row| csvf << row }
    end
  end
end
