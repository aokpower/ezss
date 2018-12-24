require_relative '../lib/ezss'

matchers = ARGV
  .map(&Spreadsheet.method(:from_file))
  .each { |ss| ss.pick_matcher(0) }
  .map(&:match_data).flatten.uniq

matchers.each { |m| puts m }
