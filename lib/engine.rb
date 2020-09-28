require 'move_logic'
require 'game_logic'

module ChessValidator
  class Engine
    class << self
      def find_next_moves(fen_notation)
        fen = PGN::FEN.new(fen_notation)
        MoveLogic.next_moves(fen)
      end

      def find_next_moves_from_moves(moves)
        fen = PGN::Game.new(moves).positions.last.to_fen
        MoveLogic.next_moves(fen)
      end

      def make_random_move(fen_notation, pieces_with_moves)
        piece_to_move = pieces_with_moves.sample
        move = piece_to_move.valid_moves.sample
        MoveLogic.make_move(piece_to_move, move, fen_notation)
      end

      def move(piece, move, fen_notation)
        MoveLogic.make_move(piece, move, fen_notation)
      end

      def pieces(fen_notation)
        fen = PGN::FEN.new(fen_notation)
        BoardLogic.build_board(fen).values
      end

      def result(fen_notation)
        GameLogic.find_game_result(fen_notation)
      end
    end
  end
end
