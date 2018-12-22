spreadsheets = ARGV.map(&Spreadsheet.method(:from_file))
spreadsheets.map(&:pick_matcher_from_prompt)
combined = Spreadsheet.combine(spreadsheets)

print('Name of output file?: ')
outfile = STDIN.gets.chomp

combined.write(outfile)
