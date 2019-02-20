#!/usr/bin/env ruby
require 'csv'
require 'pry'

# Polyfill Ruby 2.7 Array#tally
class Array
  # Counts elements in array according to id function or supplied block
  # for example [:a, :a, :b].tally #=> { a: 2, b: 1 }
  # [1, 1, 2].tally(&:even?) #=> { false => 2, true => 1 }
  def tally(&func)
    func ||= ->(x) { x } # func is id by default
    each_with_onbject(Hash.new(0)) { |v, t| t[func.call(v)] += 1 }
  end
end

# def informed_fba(list, csv)
#   csv.delete_if do |row|
#     it = row['SKU'].match(/FBA\|(.+)/)
#     it.nil? || !list.include?(it[1])
#   end
# end

# Some useful stuff to fill out CSV::Table
module ECSV
  # TODO: err if func.call(row) returns non-string
  def whitelist!(list, &func)
    func ||= ->(x) { x } # func is identity by default
    delete_if do |row|
      !list.include?(func.call(row))
    end
  end

  def write!(filename)
    # self. b/c Kernal#open is a thing. Want to be unamiguous.
    CSV.open(filename, 'w', force_quotes: true) do |outf|
      to_a.each { |row| outf << row }
    end
  end
end

CSV::Table.include ECSV

args = ARGV.map do |arg|
  {
    name: arg,
    data: case File.extname(arg)
          when '.csv'
            CSV.read(arg, headers: true) # returns CSV::Table
          when '.txt'
            # :chomp to remove line ending characters (\n & CRLF etc)
            File.readlines(arg).map(&:chomp)
          end
  }
end

p args.map { |a| a[:name] }
binding.pry