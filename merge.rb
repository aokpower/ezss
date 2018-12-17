require 'csv'

class Spreadsheet
  class << self
    def from_file(file)
      new(CSV.read(file), name: file)
    end

    def combine(spreadsheets, name: 'combined.csv')
      header = spreadsheets.flat_map(&:headers)

      # Get a unique list of matchers i.e. target cells to match with other rows
      matchers = spreadsheets.reduce([]) do |m, s|
        m.append(s.rows.map { |row| row[s.matcher_i] }).flatten
      end.uniq

      # search through spreadsheet for all rows with matching cells,
      # combine with either matching rows or Spreadsheet offsets.
      # NOTE: Hash.new {[]} b/c > x = Hash.new([]); x[:a] = x[:a] << []; x[:b] = x[:b] << []; x
      combined = Hash.new { [] }
      matchers.each do |m|
        spreadsheets.each do |ss|
          combined[m] = combined[m] << ss.rows.select { |r| r[ss.matcher_i] == m }
          # spreadsheets that have no matching rows will just be empty arrs
        end
      end

      rows = combined_to_rows(
        header: header,
        matches: combined,
        offsets: spreadsheets.map(&:offset))

      new(rows, name: name)
    end

    private

    def combined_to_rows(header:, matches:, offsets:)
      # return rows suitable for Spreadsheet or CSV input
      rows = matches.map do |(_, vs)|
        n_of_rows = vs.map(&:length).max
        r = vs.map.with_index do |ss_res, ind|
          ss_res.empty? ? [offsets[ind]] * n_of_rows : ss_res
        end
        r.shift.zip(*r)
      end

      [header, *rows.flatten(1).map(&:flatten)]
    end
  end

  attr_reader :name, :headers, :rows, :matcher_i

  def initialize(rows, name: nil, matcher_i: nil)
    @name      = name
    @headers   = rows.shift
    @rows      = rows
    @matcher_i = matcher_i
  end

  def offset
    # TODO: should offset be -1 from length?
    Array.new(headers.length, '')
  end

  def matcher
    (m = @matcher_i).nil? ? nil : headers[m]
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

  # Write out to csv file
  # def write(filename)
end
