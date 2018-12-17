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

  attr_reader :name, :headers, :rows, :matcher_i, :matcher

  def initialize(rows, name: nil, matcher: nil)
    @name    = name
    @headers = rows.shift
    @rows    = rows
    @matcher = matcher
  end

  def offset
    # TODO: test if should be -1
    Array.new(headers.length, '')
  end

  def pick_matcher
    puts "Which header do you want to match#{" for #{name}" if name}?"

    headers.each_with_index do |e, i|
      puts "#{i}) #{e}"
    end

    print('Your choice?: ')
    @matcher_i = Integer(STDIN.gets.chomp)
    @matcher   = headers[@matcher_i]
    puts("You selected #{@matcher}")
  end

  # Write out to csv file
  # def write(filename)
end

spreadsheets = ARGV.map(&Spreadsheet.method(:from_file))
spreadsheets.each(&:pick_matcher)

combined = Spreadsheet.combine(spreadsheets)
combined.rows.each do |r|
  p r
end # debug

# TODO: write combined output to file
# TODO: Separate stdin getting from pick_matcher
#       possibly by making pick_matcher yield spreadsheet?

# combined.write(output)
