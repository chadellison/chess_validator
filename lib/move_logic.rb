require_relative './constants/square_key'
require 'pry'
module ChessValidator
  class MoveLogic
    class << self
      def find_next_moves(fen_notation)
        fen = PGN::FEN.new(fen_notation)
        board = BoardLogic.build_board(fen)

        board.each do |square, piece|
          load_valid_moves(board, piece, fen)
        end
      end

      def load_valid_moves(board, piece, fen)
        moves_for_piece(piece).each do |move|
          piece.valid_moves << move if valid_move?(piece, board, move, fen)
        end
      end

      def valid_move?(piece, board, move, fen)
        case piece.piece_type.downcase
        when 'k'
          handle_king(piece, board, move, fen)
        when 'p'
          handle_pawn(piece, board, move, fen)
        else

          # valid_move_path
          # valid_destination
          # king_is_safe?
        end
      end

      def handle_king(king, board, move, fen)
        if (king.position[0].ord - move[0].ord).abs == 2
        else
          valid_destination?(king, board, move) && king_is_safe?(king, board)
        end
      end

      def king_is_safe?(king, board)
        # any pawns on diags
        # nights
        # any bishops on diags
        # any rooks
        # queens
        # kings
      end

      # def pawn_threat?(king, board)
      #
      # end

      def handle_pawn(piece, board, move, fen)
        position = piece.position

        if position[0] == move[0]
          advance_pawn?(piece, board, move)
        else
          target_piece = find_piece(board, move)
          (target_piece && target_piece.color != piece.color) || move == fen.en_passant
        end
      end

      def advance_pawn?(pawn, board, move)
        if (pawn.position[1].to_i - move[1].to_i).abs == 1
          empty_square?(board, move)
        else
          occupied_spaces = []
          board.values.each do |piece|
            occupied_spaces << piece.position if piece
          end
          valid_move_path?(pawn, move, occupied_spaces) && empty_square?(board, move)
        end
      end

      def valid_destination?(piece, board, move)
        target_piece = find_piece(board, move)
        if target_piece
          target_piece.color != piece.color
        else
          true
        end
      end

      def find_piece(board, position)
        board.values.detect { |piece| piece.position == position }
      end

      def empty_square?(board, move)
        board.values.detect { |piece| piece.position == move }.nil?
      end

      def valid_move_path?(piece, move, occupied_spaces)
        position = piece.position
        if piece.piece_type.downcase == 'n'
          true
        elsif position[0] == move[0]
          !vertical_collision?(piece.position, move, occupied_spaces)
        elsif position[1] == move[1]
          !horizontal_collision?(piece.position, move, occupied_spaces)
        else
          !diagonal_collision?(piece.position, move, occupied_spaces)
        end
      end

      def vertical_collision?(position, destination, occupied_spaces)
        row = position[1].to_i
        difference = (row - destination[1].to_i).abs - 1

        if row > destination[1].to_i
          !(moves_down(position, (difference - row).abs) & occupied_spaces).empty?
        else
          !(moves_up(position, difference + row) & occupied_spaces).empty?
        end
      end

      def horizontal_collision?(position, destination, occupied_spaces)
        if position[0] > destination[0]
          !(moves_left(position, (destination[0].ord + 1).chr) & occupied_spaces).empty?
        else
          !(moves_right(position, (destination[0].ord - 1).chr) & occupied_spaces).empty?
        end
      end

      def diagonal_collision?(position, destination, occupied_spaces)
        if position[0] < destination[0]
          horizontal_moves = moves_right(position, (destination[0].ord - 1).chr)
        else
          horizontal_moves = moves_left(position, (destination[0].ord + 1).chr)
        end
        # left or right

        difference = (position[1].to_i - destination[1].to_i).abs - 1
        if position[1] < destination[1]
          vertical_moves = moves_up(position, difference + position[1].to_i)
        else
          vertical_moves = moves_down(position, (difference - position[1].to_i).abs)
        end

        !(extract_diagonals(horizontal_moves.zip(vertical_moves)) & occupied_spaces)
          .empty?
      end

      def pinned?(piece, board, fen)
        turn = fen.active
        king = nil
        enemy_bishops = []
        enemy_rooks = []
        enemy_queen = nil

        board.values.each do |piece|
          type = piece.piece_type.downcase
          if piece.color == turn && type == 'k'
            king = piece
          elsif piece.color != turn
            enemy_bishops << piece if type == 'b'
            enemy_rooks << piece if type == 'r'
            enemy_queen = piece if type == 'q'
          end
        end

        # if any?
        # king is on same row? && enemy rook or queen shares && no pieces in between piece and king
        # king is on same column && enemy rook or queen shares && no pieces in between piece and king
        # king is on same diagonal && enemy bishop or queen shares && no pieces in between piece and king
      end

      def will_expose_king?
        # pinned? && tyring to move out of pin...
      end

      # def king_is_safe?
      # see if any enemy pieces are attacking current piece and if so, if the king is in the path
      # end

      def moves_for_piece(piece)
        case piece.piece_type.downcase
        when 'r'
          moves_for_rook(piece.position)
        when 'b'
          moves_for_bishop(piece)
        when 'q'
          moves_for_queen(piece.position)
        when 'k'
          moves_for_king(piece)
        when 'n'
          moves_for_knight(piece.square_index)
        when 'p'
          moves_for_pawn(piece)
        end
      end

      def moves_for_rook(position)
        moves_up(position) + moves_down(position) + moves_left(position) + moves_right(position)
      end

      def moves_for_bishop(position)
        top_right = moves_diagonal('up', 'right', position)
        top_left = moves_diagonal('up', 'left', position)
        bottom_left = moves_diagonal('down', 'left', position)
        bottom_right = moves_diagonal('down', 'right', position)

        top_right + top_left + bottom_left + bottom_right
      end

      def moves_diagonal(vertical, horizontal, position)
        column = position[0]
        row = position[1]
        possible_moves = []

        while column > 'a' && column < 'h' && row > '1' && row < '8' do
          column = horizontal == 'left' ? previous_char(column) : column.next
          row = vertical == 'up' ? row.next : previous_char(row)
          possible_moves << column + row
        end
        possible_moves
      end

      def previous_char(char)
        (char.ord - 1).chr
      end

      def moves_for_queen(position)
        moves_for_rook(position) + moves_for_bishop(position)
      end

      def spaces_near_king(index)
        [
          SQUARE_KEY[index - 1], SQUARE_KEY[index + 1],
          SQUARE_KEY[index - 7], SQUARE_KEY[index - 8], SQUARE_KEY[index - 9],
          SQUARE_KEY[index + 7], SQUARE_KEY[index + 8], SQUARE_KEY[index + 9]
        ].compact
      end

      def moves_for_king(piece)
        position = piece.position
        castle_moves = [(position[0].ord - 2).chr + position[1], position[0].next.next + position[1]]
        spaces_near_king(piece.square_index) + castle_moves
      end

      def moves_for_knight(index)
        [
          SQUARE_KEY[index - 10], SQUARE_KEY[index - 17], SQUARE_KEY[index - 15],
          SQUARE_KEY[index - 6], SQUARE_KEY[index + 10], SQUARE_KEY[index + 17],
          SQUARE_KEY[index + 15], SQUARE_KEY[index + 6]
        ].compact
      end

      def moves_for_pawn(pawn)
        position = pawn.position
        left_letter = (position[0].ord - 1).chr
        right_letter = (position[0].ord + 1).chr


        up_count = position[1].to_i + 1
        down_count = position[1].to_i - 1

        one_forward = pawn.color == 'w' ? position[1].to_i + 1 : position[1].to_i - 1

        possible_moves = [
          left_letter[0] + one_forward.to_s,
          right_letter[0] + one_forward.to_s,
          position[0] + one_forward.to_s,
        ]

        if pawn.color == 'w' && position[1] == '2' || pawn.color == 'b' && position[1] == '7'
          two_forward = pawn.color == 'w' ? up_count + 1 : (down_count - 1)
          possible_moves << position[0] + two_forward.to_s
        end

        remove_out_of_bounds_moves(possible_moves)
      end

      def remove_out_of_bounds_moves(moves)
        moves.reject do |move|
          move[0] < 'a' ||
            move[0] > 'h' ||
            move[1..-1].to_i < 1 ||
            move[1..-1].to_i > 8
        end
      end

      def extract_diagonals(moves)
        moves.map do |move_pair|
          (move_pair[0][0] + move_pair[1][1]) unless move_pair.include?(nil)
        end.compact
      end

      def moves_up(position, count = 8)
        possible_moves = []
        row = position[1].to_i

        while row < count
          row += 1
          possible_moves << (position[0] + row.to_s)
        end
        possible_moves
      end

      def moves_down(position, count = 1)
        possible_moves = []
        row = position[1].to_i

        while row > count
          row -= 1
          possible_moves << (position[0] + row.to_s)
        end
        possible_moves
      end

      def moves_left(position, letter = 'a')
        possible_moves = []
        column = position[0]

        while column > letter
          column = (column.ord - 1).chr

          possible_moves << (column + position[1])
        end
        possible_moves
      end

      def moves_right(position, letter = 'h')
        possible_moves = []
        column = position[0]

        while column < letter
          column = column.next

          possible_moves << (column + position[1])
        end
        possible_moves
      end
    end
  end
end
