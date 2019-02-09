require 'rltk' # Doing this without a proper lexer library is a FUUUCKING hassle
# NOTES:
# Need to reverse parse with respect to headers
# Separate matching headers and finding cell separations / dequoting

class IdealLexer < RLTK::Lexer
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
    out = lex(line)
    result = []
    cell = []

    out.each do |token|
      if [:CellDelimiter, :EOS].include? token.type
        result << cell.join
        cell = []
      else
        cell << token.value
      end
    end

    result
  end
end
