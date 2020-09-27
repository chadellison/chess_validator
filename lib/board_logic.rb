require 'piece'

module ChessValidator
  class BoardLogic
    def self.build_board(fen)
      board = {}
      square_index = 1
      fen.board_string.chars.each do |char|
        if empty_square?(char)
          square_index += char.to_i
        elsif char != '/'
          board[square_index] = Piece.new(char, square_index)
          square_index += 1
        end
      end

      board
    end

    def self.to_fen_notation(board, previous_fen, piece, move)
      notation = handle_position(board)
      notation += find_turn(previous_fen.active)
      notation += handle_castle(previous_fen.castling, piece)
      notation += handle_en_passant(piece, move)
      notation += handle_half_move_clock(board.size, previous_fen, piece)
      notation += piece.color == 'b' ? previous_fen.fullmove.next : previous_fen.fullmove
      notation
    end

    def self.handle_half_move_clock(board_size, previous_fen, piece)
      if piece.piece_type == 'pawn' || build_board(previous_fen).size > board_size
        '0 '
      else
        previous_fen.halfmove.next + ' '
      end
    end

    def self.handle_castle(castling, piece)
      return castling if castling == '-'
      if ['K', 'Q', 'k', 'q'].include?(piece.piece_type)
        castling.size == 1 ? '-' : castling.delete(piece.piece_type)
      elsif piece.piece_type.downcase == 'r'
        castle_side = piece.position[0] == 'a' ? 'q' : 'k'
        castle_side = castle_side.capitalize if piece.color == 'w'
        castling.size == 1 ? '-' : castling.delete(castle_side)
      else
        castling
      end
    end

    def self.handle_en_passant(piece, move)
      en_passant = ' - '
      if (piece.piece_type.downcase == 'p' && (piece.position[1].to_i - move[1].to_i).abs > 1)
        column = piece.color == 'w' ? '3' : '6'
        ' ' + piece.position[0] + column + ' '
      else
        ' - '
      end
    end

    def self.handle_position(board)
      notation = ''
      square_gap = 0
      64.times do |n|
        if n > 0 && n % 8 == 0
          notation += square_gap.to_s if square_gap > 0
          notation += '/'
          square_gap = 0
        end

        piece = board[n + 1]
        if piece
          notation += square_gap.to_s if square_gap > 0
          notation += piece.piece_type
          square_gap = 0
        elsif n < 63
          square_gap += 1
        else
          notation += (square_gap + 1).to_s
        end
      end
      notation
    end

    def self.find_turn(current_turn)
      current_turn == 'w' ? ' b ' : ' w '
    end

    def self.empty_square?(char)
      ('1'..'8').include?(char)
    end
  end
end
