require_relative '../lib/ezss'
# meant to be used with a file of master skus and a product export file from skubana
listed_skus = File.readlines(ARGV[0]).map(&:chomp)
master_products = Spreadsheet.from_file(ARGV[1])
master_products.pick_matcher(0)

def count_active(ss)
  ss.rows.map { |r| r[20] }.count {|v| v.downcase == 'true'}
end

puts '# of active products before: ' + count_active(master_products).to_s

master_products.map! do |row, ss|
  matcher = row[ss.matcher_i]
  unless listed_skus.include? matcher
    row[20] = 'false'
  end
  row
end

puts '# of active products after: ' + count_active(master_products).to_s

print('Name of output file?: ')
outfile = STDIN.gets.chomp
master_products.write(outfile)
