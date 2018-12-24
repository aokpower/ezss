require_relative '../lib/ezss'

spreadsheet = Spreadsheet.from_file ARGV[0]

duplicates = 0 # STATS
spreadsheet.pick_matcher(0) # 0 = Master Sku index

    ss.map! do |row, ss|
      m = row[ss.matcher_i]
      row.tap { |r| exists[m] ? row[0] = 'changed' : exists[m] = true }
    end

exists = {}
spreadsheet.map! do |row, ss|
  m = row[ss.matcher_i]
  row.tap { |r| exists[m] ? row[0] = 'false'; duplicates += 1 : exists[m] = true }
end

puts "There were #{duplicates} duplicates"

print('Name of output file?: ')
outfile = STDIN.gets.chomp

spreadsheet.write(outfile)
