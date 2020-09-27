require 'board_logic'
require 'move_logic'
require 'pgn'

module ChessValidator
  class GameLogic
    class << self
      def find_game_result(fen_notation)
        fen = PGN::FEN.new(fen_notation)
        board = BoardLogic.build_board(fen)
        no_moves = MoveLogic.next_moves(fen).empty?
        checkmate_result = checkmate_value(fen, board, no_moves)

        if checkmate_result
          checkmate_result
        elsif draw?(fen, board, no_moves)
          '1/2-1/2'
        end
      end

      def checkmate_value(fen, board, no_moves)
        king, occupied_spaces = MoveLogic.find_king_and_spaces(board, fen.active)
        in_check = !MoveLogic.king_is_safe?(fen.active, board, king.position, occupied_spaces)

        if no_moves && in_check
          fen.active == 'w' ? '0-1' : '1-0'
        end
      end

      def draw?(fen, board, no_moves)
        [fen.halfmove == '50', no_moves, insufficient_material?(board)].any?
      end

      def insufficient_material?(board)
        if board.size < 4
          board.values.none? { |piece| ['q', 'r', 'p'].include?(piece.piece_type.downcase) }
        end
      end
    end
  end
end
