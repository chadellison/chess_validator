require_relative './constants/square_key'
require 'pry'
module ChessValidator
  class MoveLogic
    class << self
      def find_next_moves(fen_notation)
        fen = PGN::FEN.new(fen_notation)
        board = BoardLogic.build_board(fen)

        pieces = board.values.map do |piece|
          load_valid_moves(board, piece, fen) if piece
        end.compact
        # return pieces
      end

      def load_valid_moves(board, piece, fen)
        moves_for_piece(piece).each do |move|
          piece.valid_moves << move if valid_move?(piece, board, move, fen)
        end
      end

      def valid_move?(piece, board, move, fen)
        occupied_spaces = []
        board.values.each { |p| occupied_spaces << p.position if p }
        case piece.piece_type.downcase
        when 'k'
          handle_king(piece, board, move, fen)
        when 'p'
          handle_pawn(piece, board, move, fen)
        else
          valid_move_path?(piece, king_move, occupied_spaces) &&
          valid_destination?(piece, board, move) &&
          king_will_be_safe?(piece, board, move)
        end
      end

      def king_will_be_safe?(piece, board, move)
        index = INDEX_KEY[move]
        new_board = board.clone
        new_board[piece.index] = nil
        new_board[index] = piece
        king = board.values.detect { |p| p.piece_type.downcase == 'k' && p.color == piece.color }
        king_is_safe?(king.color, new_board, king.position)
      end

      def handle_king(king, board, move, fen)
        if (king.position[0].ord - move[0].ord).abs == 2
          empty_b_square = true
          if move[0] == 'c'
            castle_code = 'q'
            between = 'd' + move[1]
            empty_b_square = empty_square?(board, 'b' + move[1])
          else
            castle_code = 'k'
            between = 'f' + move[1]
          end
          (fen.castling.include?(castle_code) && king.color == 'b' || fen.castling.include?(castle_code.upcase) && king.color == 'w') &&
          king_is_safe?(king.color, board, king.position) &&
          king_is_safe?(king.color, board, between) &&
          king_is_safe?(king.color, board, move) &&
          board.values.none? { |piece| [between, move].include?(piece.position) } &&
          empty_b_square
        else
          valid_destination?(king, board, move) && king_is_safe?(king.color, board, move)
        end
      end

      def king_is_safe?(king_color, board, king_move)
        occupied_spaces = []
        pieces = board.values
        pieces.each { |piece| occupied_spaces << piece.position if piece }

        pieces.none? do |piece|
          piece.color != king_color &&
          moves_for_piece(piece).select do |move|
            king_move == move && valid_move_path?(piece, king_move, occupied_spaces)
          end.size > 0
        end
      end

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
          !collision?(piece.position, move, occupied_spaces, 1, 0)
        elsif position[1] == move[1]
          !collision?(piece.position, move, occupied_spaces, 0, 1)
        else
          !diagonal_collision?(piece.position, move, occupied_spaces)
        end
      end

      def collision?(position, destination, occupied_spaces, i1, i2)
        start_index = position[i1]
        end_index = destination[i1]

        if start_index > end_index
          start_index = destination[i1]
          end_index = position[i1]
        end

        occupied_spaces.select do |space|
          space[i2] == position[i2] && space[i1] > start_index && space[i1] < end_index
        end.size > 0
      end

      def diagonal_collision?(position, destination, occupied_spaces)
        difference = (position[1].to_i - destination[1].to_i).abs - 1

        horizontal_multiplyer = 1
        horizontal_multiplyer = -1 if position[0] > destination[0]

        vertical_multiplyer = 1
        vertical_multiplyer = -1 if position[1] > destination[1]

        move_path = []
        difference.times do |n|
          column = (position[0].ord + ((n + 1) * horizontal_multiplyer)).chr
          row = (position[1].to_i + ((n + 1) * vertical_multiplyer)).to_s
          move_path << column + row
        end

        !(move_path & occupied_spaces).empty?
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
      end

      def moves_for_piece(piece)
        case piece.piece_type.downcase
        when 'r'
          moves_for_rook(piece.position)
        when 'b'
          moves_for_bishop(piece.position)
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
        moves_horizontal(position) + moves_vertical(position)
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
        possible_moves = []

        if pawn.color == 'w'
          sum1 = -9
          sum2 = -8
          sum3 = -7
        else
          sum1 = 9
          sum2 = 8
          sum3 = 7
        end

        possible_moves << SQUARE_KEY[pawn.square_index + sum1]
        possible_moves << SQUARE_KEY[pawn.square_index + sum2]
        possible_moves << SQUARE_KEY[pawn.square_index + sum3]

        if pawn.color == 'w' && pawn.position[1] == '2' || pawn.color == 'b' && pawn.position[1] == '7'
          two_forward = pawn.color == 'w' ? -16 : 16
          possible_moves << SQUARE_KEY[pawn.square_index + two_forward]
        end

        possible_moves.compact
      end

      def moves_horizontal(position)
        possible_moves = []
        column = 'a'
        row = position[1]

        8.times do
          possible_moves << column + row unless column == position[0]
          column = column.next
        end

        possible_moves
      end

      def moves_vertical(position)
        possible_moves = []
        column = position[0]
        row = '1'

        8.times do
          possible_moves << column + row unless row == position[1]
          row = row.next
        end

        possible_moves
      end
    end
  end
end
