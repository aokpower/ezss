require 'rltk' # Doing this without a proper lexer library is a FUUUCKING hassle

# NOTES:
# Need to reverse parse with respect to headers
# Separate matching headers and finding cell separations / dequoting
# IDEAL (lol) export rows DON'T HAVE A FIXED NUMBER OF CELLS
# Yes; this means that you have to figure out what cells corespond to which
# headers by implication of the content. How idealistic. Not by the header, but
# by the content of their cell's. I'm downright touched.

module Ideal
  class Lexer < RLTK::Lexer
    # :default state rules
    rule(/""/)           { [:Char, '"'] }
    rule(/[^",]/)        { |c| [:Char, c] }
    rule(/,/)            { :CellDelimiter }
    rule(/(?<!")"(?!")/) { push_state(:quoted) }

    # :quoted state rules
    rule(/""/, :quoted)           { [:Char, '"'] }
    rule(/[^"]/, :quoted)         { |c| [:Char, c] }
    rule(/(?<!")"(?!")/, :quoted) { pop_state }

    def read_line(line)
      result = []
      cell   = []

      lex(line).each do |token|
        if [:CellDelimiter, :EOS].include? token.type
          result << cell.join
          cell = [] # If :EOS cell won't get put into result before enumeration end
        elsif token.type == :Char
          cell << token.value
        else # JIC, if I'm poking around with lexer rules this might save me some time headscratching
          raise "Unknown token type #{token.type}. Value: #{token.value}"
        end
      end

      result
    end
  end
end
