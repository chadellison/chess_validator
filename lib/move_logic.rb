require 'board_logic'
require 'pgn'

module ChessValidator
  class MoveLogic
    class << self
      def next_moves(fen)
        board = BoardLogic.build_board(fen)
        pieces = []
        board.values.each do |piece|
          if piece.color == fen.active
            load_move_data(board, piece, fen)
            pieces << piece if piece.valid_moves.size > 0
          end
        end

        pieces
      end

      def load_move_data(board, piece, fen)
        moves_for_piece(piece).each do |move|
          if valid_move?(piece, board, move, fen)
            piece.valid_moves << move
            target = find_target(board, piece, move, fen.en_passant)
            piece.targets << target if target
          else
            piece.move_potential << move
          end
        end
      end

      def find_target(board, piece, move, en_passant)
        if piece.piece_type.downcase == 'p' && piece.position[0] == move[0]
          nil
        elsif board[INDEX_KEY[move]]
          board[INDEX_KEY[move]]
        elsif piece.piece_type.downcase == 'p' && move == en_passant
          en_passant_position = piece.color == 'w' ? move[0] + '5' : move[0] + '4'
          board[INDEX_KEY[en_passant_position]]
        end
      end

      def valid_move?(piece, board, move, fen)
        occupied_spaces = []
        board.values.each { |p| occupied_spaces << p.position }
        case piece.piece_type.downcase
        when 'k'
          handle_king(piece, board, move, fen, occupied_spaces)
        when 'p'
          handle_pawn(piece, board, move, fen)
        else
          valid_move_path?(piece, move, occupied_spaces) &&
          valid_destination?(piece, board, move) &&
          king_will_be_safe?(piece, board, move)
        end
      end

      def with_next_move(piece, board, move)
        index = INDEX_KEY[move]
        new_board = board.clone
        piece_type = resolve_piece_type(piece.piece_type, move)
        new_piece = Piece.new(piece_type, index)
        new_board.delete(piece.square_index)
        new_board[index] = new_piece
        new_board = handle_castle(new_board, move) if castled?(piece, move)
        new_board = handle_en_passant(new_board, piece.color, move) if en_passant?(piece, move, new_board[index])
        new_board
      end

      def resolve_piece_type(piece_type, move)
        if piece_type.downcase == 'p' && ['1', '8'].include?(move[1])
          move[1] == '8' ? 'Q' : 'q'
        else
          piece_type
        end
      end

      def handle_en_passant(board, pawn_color, move)
        if pawn_color == 'w'
          index = INDEX_KEY[move[0] + '5']
        else
          index = INDEX_KEY[move[0] + '4']
        end

        board.delete(index)
        board
      end

      def handle_castle(board, move)
        case move
        when 'c1'
          board.delete(57)
          board[60] = Piece.new('R', 60)
        when 'g1'
          board.delete(64)
          board[62] = Piece.new('R', 62)
        when 'c8'
          board.delete(1)
          board[4] = Piece.new('r', 4)
        when 'g8'
          board.delete(8)
          board[6] = Piece.new('r', 6)
        end

        board
      end

      def make_random_move(fen_notation, pieces_with_moves)
        piece_to_move = pieces_with_moves.sample
        move = piece_to_move.valid_moves.sample
        make_move(piece_to_move, move, fen_notation)
      end

      def make_move(piece, move, fen_notation)
        fen = PGN::FEN.new(fen_notation)
        board = BoardLogic.build_board(fen)
        new_board = with_next_move(piece, board, move)

        BoardLogic.to_fen_notation(new_board, fen, piece, move)
      end

      def castled?(piece, move)
        piece.piece_type.downcase == 'k' && (piece.position[0].ord - move[0].ord).abs == 2
      end

      def en_passant?(piece, move, square)
        piece.piece_type.downcase == 'p' && piece.position[0] != move[0] && !square
      end

      def king_will_be_safe?(piece, board, move)
        new_board = with_next_move(piece, board, move)
        king, occupied_spaces = find_king_and_spaces(new_board, piece.color)
        king_is_safe?(king.color, new_board, king.position, occupied_spaces)
      end

      def find_king_and_spaces(board, color)
        occupied_spaces = []
        king = nil
        board.values.each do |p|
          king = p if p.piece_type.downcase == 'k' && p.color == color
          occupied_spaces << p.position
        end
        [king, occupied_spaces]
      end

      def handle_king(king, board, move, fen, occupied_spaces)
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
          king_is_safe?(king.color, board, king.position, occupied_spaces) &&
          king_is_safe?(king.color, board, between, occupied_spaces) &&
          king_is_safe?(king.color, board, move, occupied_spaces) &&
          board.values.none? { |piece| [between, move].include?(piece.position) } &&
          empty_b_square
        else
          valid_destination?(king, board, move) && king_is_safe?(king.color, board, move, occupied_spaces)
        end
      end

      def king_is_safe?(king_color, board, king_position, occupied_spaces)
        board.values.none? do |piece|
          piece.color != king_color &&
          moves_for_piece(piece).any? do |move|
            if piece.piece_type.downcase == 'p'
              king_position == move && piece.position[0] != king_position[0]
            else
              king_position == move && valid_move_path?(piece, king_position, occupied_spaces)
            end
          end
        end
      end

      def handle_pawn(piece, board, move, fen)
        position = piece.position

        if position[0] == move[0]
          valid = advance_pawn?(piece, board, move)
        else
          target_piece = find_piece(board, move)
          valid = (target_piece && target_piece.color != piece.color) || move == fen.en_passant
        end
        valid && king_will_be_safe?(piece, board, move)
      end

      def advance_pawn?(pawn, board, move)
        if empty_square?(board, forward_by(pawn, 1))
          if (pawn.position[1].to_i - move[1].to_i).abs == 2
            empty_square?(board, forward_by(pawn, 2))
          else
            true
          end
        else
          false
        end
      end

      def forward_by(piece, count)
        position = piece.position
        piece.color == 'w' ? position[0] + (position[1].to_i + count).to_s : position[0] + (position[1].to_i - count).to_s
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
        board.values.none? { |piece| piece.position == move }
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

      def moves_for_piece(piece)
        case piece.piece_type.downcase
        when 'r'
          moves_for_rook(piece.position)
        when 'b'
          moves_for_bishop(piece.position)
        when 'q'
          moves_for_queen(piece.position)
        when 'k'
          moves_for_king(piece.position)
        when 'n'
          moves_for_knight(piece.position)
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

        while column >= 'a' && column <= 'h' && row >= '1' && row <= '8' do
          column = horizontal == 'left' ? previous_char(column) : column.next
          row = vertical == 'up' ? row.next : previous_char(row)
          possible_moves << column + row
        end
        remove_out_of_bounds(possible_moves)
      end

      def previous_char(char)
        (char.ord - 1).chr
      end

      def moves_for_queen(position)
        moves_for_rook(position) + moves_for_bishop(position)
      end

      def spaces_near_king(position)
        column = position[0].ord
        row = position[1].to_i

        moves = [
          (column - 1).chr + row.to_s,
          (column + 1).chr + row.to_s,
          (column - 1).chr + (row - 1).to_s,
          (column - 1).chr + (row + 1).to_s,
          (column + 1).chr + (row - 1).to_s,
          (column + 1).chr + (row + 1).to_s,
          column.chr + (row + 1).to_s,
          column.chr + (row - 1).to_s
        ]
        remove_out_of_bounds(moves)
      end

      def moves_for_king(position)
        castle_moves = [(position[0].ord - 2).chr + position[1], position[0].next.next + position[1]]
        remove_out_of_bounds(spaces_near_king(position) + castle_moves)
      end

      def moves_for_knight(position)
        column = position[0].ord
        row = position[1].to_i

        moves = [
          (column - 2).chr + (row + 1).to_s,
          (column - 2).chr + (row - 1).to_s,
          (column + 2).chr + (row + 1).to_s,
          (column + 2).chr + (row - 1).to_s,
          (column - 1).chr + (row + 2).to_s,
          (column - 1).chr + (row - 2).to_s,
          (column + 1).chr + (row + 2).to_s,
          (column + 1).chr + (row - 2).to_s
        ]

        remove_out_of_bounds(moves)
      end

      def remove_out_of_bounds(moves)
        moves.select { |move| ('a'..'h').include?(move[0]) && ('1'..'8').include?(move[1..-1]) }
      end

      def moves_for_pawn(pawn)
        column = pawn.position[0].ord
        row = pawn.color == 'w' ? pawn.position[1].to_i + 1 : pawn.position[1].to_i - 1

        moves = [
          (column - 1).chr + row.to_s,
          (column + 1).chr + row.to_s,
          column.chr + row.to_s
        ]

        if pawn.color == 'w' && pawn.position[1] == '2' || pawn.color == 'b' && pawn.position[1] == '7'
          two_forward = pawn.color == 'w' ? row + 1 : row - 1
          moves << column.chr + two_forward.to_s
        end
        remove_out_of_bounds(moves)
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
