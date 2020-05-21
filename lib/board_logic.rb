require 'piece'

module ChessValidator
  class BoardLogic
    def self.build_board(fen)
      board = {}
      square_index = 1
      fen.to_s.split(' ').first.chars.each do |char|
        if empty_square?(char)
          square_index += char.to_i
        elsif char != '/'
          board[square_index] = Piece.new(char, square_index)
          square_index += 1
        end
      end

      board
    end

    def self.empty_square?(char)
      ('1'..'8').include?(char)
    end
  end
end
