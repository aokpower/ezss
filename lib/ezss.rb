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

  def offset
    Array.new(headers.length, '')
  end

  def matcher
    @matcher_i && headers[@matcher_i]
  end

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

  def match_data
    rows.map { |row| row[matcher_i] }
  end

  def pick_matcher(ind = nil)
    @matcher_i = ind || yield(headers)
  end

  def pick_matcher_from_prompt
    pick_matcher do |headers|
      puts "Which header do you want to match#{" for #{name}" if name}?"
      headers.each_with_index { |h, i| puts "#{i}) #{h}" }

      print('Your choice?: '); Integer(STDIN.gets.chomp)
    end
  end

  def write(filename)
    CSV.open(filename, 'w', force_quotes: true) do |csvf|
      csvf << headers
      rows.each { |row| csvf << row }
    end
  end
end
