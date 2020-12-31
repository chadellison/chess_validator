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

    def self.to_fen_notation(board, previous_fen, piece, move, captured)
      notation = handle_position(board)
      notation += find_turn(previous_fen.active)
      notation += handle_castle(previous_fen.castling, piece, board)
      notation += handle_en_passant(piece, move)
      notation += handle_half_move_clock(previous_fen, piece.piece_type, captured)
      notation += piece.color == 'b' ? previous_fen.fullmove.next : previous_fen.fullmove
      notation
    end

    def self.handle_half_move_clock(previous_fen, piece_type, captured)
      if piece_type.downcase == 'p' || captured
        '0 '
      else
        previous_fen.halfmove.next + ' '
      end
    end

    def self.handle_castle(castling, piece, board)
      return castling if castling == '-'
      castling.delete!('K') if board[64].nil? || board[64].piece_type != 'R'
      castling.delete!('K') if board[61].nil? || board[61].piece_type != 'K'
      castling.delete!('Q') if board[57].nil? || board[57].piece_type != 'R'
      castling.delete!('k') if board[8].nil? || board[8].piece_type != 'r'
      castling.delete!('k') if board[5].nil? || board[5].piece_type != 'k'
      castling.delete!('q') if board[1].nil? || board[1].piece_type != 'r'
      castling.size == 1 ? '-' : castling
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
