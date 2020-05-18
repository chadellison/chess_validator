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
          handle_king
        when 'p'
          handle_pawn
        when 'n'
        else
          # valid_move_path
          # valid_destination
          # king_is_safe?
        end
      end

      def handle_king(position, board, move, fen)

      end

      def handle_pawn(position, board, move, fen)
        if position[0] == move[0]
          if (position[1].to_i - move[1].to_i).abs == 1
            empty_square?(board, move)
          else

            empty_square?(board, move)
          end
        else
        end
      end

      def empty_square?(board, move)
        board.values.detect { |piece| piece.position == move }.blank?
      end

      def valid_move_path?(piece, move, occupied_spaces)
        if piece.piece_type.downcase == 'n'
          true
        elsif position[0] == move[0]
          !vertical_collision?(piece.position, move, occupied_spaces)
        elsif position[1] == move[1]
          !horizontal_collision?(move, occupied_spaces)
        else
          !diagonal_collision?(move, occupied_spaces)
        end
      end

      def vertical_collision?(position, move, occupied_spaces)
        row = position[1].to_i
        difference = (row - move[1].to_i).abs - 1

        spaces = []
        if row > move[1].to_i
          difference.times { |n| spaces << move[0] + (position[1].to_i - (n + 1)).to_s }
        else
          difference.times { |n| spaces << move[0] + (position[1].to_i + (n + 1)).to_s }
        end

        !(occupied_spaces & spaces).empty?
      end

      def horizontal_collision?(destination, occupied_spaces)
        if position[0] > destination[0]
          (moves_left((destination[0].ord + 1).chr) & occupied_spaces).present?
        else
          (moves_right((destination[0].ord - 1).chr) & occupied_spaces).present?
        end
      end

      # def diagonal_collision?(destination, occupied_spaces)
      #   if position[0] < destination[0]
      #     horizontal_moves = moves_right((destination[0].ord - 1).chr)
      #   else
      #     horizontal_moves = moves_left((destination[0].ord + 1).chr)
      #   end
      #
      #   difference = (position[1].to_i - destination[1].to_i).abs - 1
      #   if position[1] < destination[1]
      #     vertical_moves = moves_up(difference + position[1].to_i)
      #   else
      #     vertical_moves = moves_down((difference - position[1].to_i).abs)
      #   end
      #   (extract_diagonals(horizontal_moves.zip(vertical_moves)) & occupied_spaces)
      #     .present?
      # end

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
        moves_up(position) + moves_down(position) + moves_left(position) + moves_right(position)
      end

      def moves_for_bishop(position)
        top_right = extract_diagonals(moves_right(position).zip(moves_up(position)))
        top_left = extract_diagonals(moves_left(position).zip(moves_up(position)))
        bottom_left = extract_diagonals(moves_left(position).zip(moves_down(position)))
        bottom_right = extract_diagonals(moves_right(position).zip(moves_down(position)))

        top_right + top_left + bottom_left + bottom_right
      end

      def moves_for_queen(position)
        moves_for_rook(position) + moves_for_bishop(position)
      end

      def spaces_near_king(position)
        moves = [
          (position[0].ord - 1).chr + position[1],
          (position[0].ord - 1).chr + (position[1].to_i + 1).to_s,
          position[0] + (position[1].to_i + 1).to_s,
          (position[0].ord + 1).chr + (position[1].to_i + 1).to_s,
          (position[0].ord + 1).chr + position[1],
          (position[0].ord + 1).chr + (position[1].to_i - 1).to_s,
          (position[0] + (position[1].to_i - 1).to_s),
          (position[0].ord - 1).chr + (position[1].to_i - 1).to_s,
        ]
        remove_out_of_bounds_moves(moves)
      end

      def moves_for_king(position)
        castle_moves = [(position[0].ord - 2).chr + position[1], position[0].next.next + position[1]]
        spaces_near_king(position) + castle_moves
      end

      def moves_for_knight(position)
        moves = []
        column = position[0].ord
        row = position[1].to_i

        moves << (column - 2).chr + (row + 1).to_s
        moves << (column - 2).chr + (row - 1).to_s

        moves << (column + 2).chr + (row + 1).to_s
        moves << (column + 2).chr + (row - 1).to_s

        moves << (column - 1).chr + (row + 2).to_s
        moves << (column - 1).chr + (row - 2).to_s

        moves << (column + 1).chr + (row + 2).to_s
        moves << (column + 1).chr + (row - 2).to_s

        remove_out_of_bounds_moves(moves)
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

      def moves_up(position)
        possible_moves = []
        row = position[1].to_i

        while row < 8
          row += 1
          possible_moves << (position[0] + row.to_s)
        end
        possible_moves
      end

      def moves_down(position)
        possible_moves = []
        row = position[1].to_i

        while row > 1
          row -= 1
          possible_moves << (position[0] + row.to_s)
        end
        possible_moves
      end

      def moves_left(position)
        possible_moves = []
        column = position[0]

        while column > 'a'
          column = (column.ord - 1).chr

          possible_moves << (column + position[1])
        end
        possible_moves
      end

      def moves_right(position)
        possible_moves = []
        column = position[0]

        while column < 'h'
          column = column.next

          possible_moves << (column + position[1])
        end
        possible_moves
      end
    end
  end
end
