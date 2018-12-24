require_relative '../lib/ezss'

spreadsheet = Spreadsheet.from_file ARGV[0]

duplicates = 0 # STATS
spreadsheet.pick_matcher(0) # 0 = Master Sku index

spreadsheet.map_duplicates! do |row|
  row[3] = 'FALSE'
  duplicates += 1
end

puts "There were #{duplicates} duplicates"

print('Name of output file?: ')
outfile = STDIN.gets.chomp

spreadsheet.write(outfile)
