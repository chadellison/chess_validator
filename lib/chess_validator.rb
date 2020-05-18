module ChessValidator
  class MoveValidator
    def self.valid?(fen_notation, next_move)
      # fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
      # board = BoardLogic.build_board(fen)

    end

    def self.next_moves(fen_notation)
      fen = PGN::FEN.new(fen_notation)
      MoveLogic.find_next_moves(fen)
    end
  end
end
