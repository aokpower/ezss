require 'csv'

class Spreadsheet
  class << self
    def from_file(file, matcher_i: nil)
      new(CSV.read(file), name: file, matcher_i: matcher_i)
    end

    def combine(spreadsheets)
      # Get a unique list of matchers i.e. target cells to match with other rows
      matchers = spreadsheets.reduce([]) do |m, s|
        m.append(s.rows.map { |row| row[s.matcher_i] }).flatten
      end.uniq

      # NOTE: Hash.new {[]} b/c:
      # > x = Hash.new([]); x[:a] = x[:a] << []; x[:b] = x[:b] << []; x
      matches = Hash.new { [] }
      matchers.each do |m|
        spreadsheets.each do |ss|
          r = ss.rows.select { |r| r[ss.matcher_i] == m }
          matches[m] = matches[m] << (r.empty? ? [ss.offset] : r)
        end
      end

      rows = matches.values
                    .flat_map { |ms| ms.shift.product(*ms) }
                    .map(&:flatten)
      new([spreadsheets.flat_map(&:headers), *rows], name: name)
    end
  end

  attr_reader :name, :headers, :rows, :matcher_i

  def initialize(rows, name: nil, matcher_i: nil)
    rows       = rows.clone # don't modify original rows arr, work from a new 1
    @name      = name
    @headers   = rows.shift
    @rows      = rows
    @matcher_i = matcher_i
  end

  def offset
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
