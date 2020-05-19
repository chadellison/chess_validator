require 'move_logic'
require 'piece'
require 'pgn'

RSpec.describe ChessValidator::MoveLogic do
  describe 'moves_for_rook' do
    it 'returns an array of all possible moves for a rook in a given position' do
      expected = ['d5', 'd6', 'd7', 'd8', 'd3', 'd2', 'd1', 'c4', 'b4', 'a4',
                  'e4', 'f4', 'g4', 'h4'].sort

      expect(ChessValidator::MoveLogic.moves_for_rook('d4').sort).to eq expected
    end
  end

  describe 'moves_for_bishop' do
    it 'returns an array of all possible moves for a bishop in a given position' do
      expected = ['e5', 'f6', 'g7', 'h8', 'c5', 'b6', 'a7', 'c3', 'b2', 'a1',
                  'e3', 'f2', 'g1']

      expect(ChessValidator::MoveLogic.moves_for_bishop('d4')).to eq expected
    end

    context 'when the bishop is on c7' do
      it 'returns an array of all possible moves for a bishop in a given position' do
        expected = ['b8', 'd8', 'b6', 'a5', 'd6', 'e5', 'f4', 'g3', 'h2'].sort

        expect(ChessValidator::MoveLogic.moves_for_bishop('c7').sort).to eq expected
      end
    end
  end

  describe 'moves_for_queen' do
    it 'returns an array of all possible moves for a queen in a given position' do
      expected = ['d5', 'd6', 'd7', 'd8', 'd3', 'd2', 'd1', 'c4', 'b4', 'a4',
                  'e4', 'f4', 'g4', 'h4', 'e5', 'f6', 'g7', 'h8', 'c5', 'b6',
                  'a7', 'c3', 'b2', 'a1', 'e3', 'f2', 'g1'].sort

      expect(ChessValidator::MoveLogic.moves_for_queen('d4').sort).to eq expected
    end
  end

  describe 'moves_for_king' do
    it 'returns an array of all possible moves for a king in a given position' do
      piece = ChessValidator::Piece.new('K', 36)
      expected = ['d5', 'd3', 'c4', 'e4', 'e5', 'c5', 'c3', 'e3', 'b4', 'f4'].sort

      expect(ChessValidator::MoveLogic.moves_for_king(piece).sort).to eq expected
    end
  end

  describe 'moves_for_knight' do
    it 'returns an array of all possible moves for a knight in a given position' do
      expected = ['b5', 'b3', 'f5', 'f3', 'c6', 'c2', 'e6', 'e2'].sort

      piece = ChessValidator::Piece.new('N', 36)
      expect(ChessValidator::MoveLogic.moves_for_knight(piece.square_index).sort).to eq expected
    end
  end

  describe 'moves_for_pawn' do
    context 'when the pawn is on d4' do
      it 'returns an array of all possible moves for a pawn (of either color) in a given position' do
        piece = ChessValidator::Piece.new('p', 36)
        expected = ["c3", "e3", "d3"].sort

        expect(ChessValidator::MoveLogic.moves_for_pawn(piece).sort).to eq expected
      end
    end

    context 'when the pawn is on its starting square' do
      it 'returns an array of all possible moves for a pawn (of either color) in a given position' do
        piece = ChessValidator::Piece.new('P', 52)
        expected = ["c3", "e3", "d3", "d4"].sort

        expect(ChessValidator::MoveLogic.moves_for_pawn(piece).sort).to eq expected
      end
    end
  end

  describe 'vertical_collision?' do
    context 'when there is a piece above in the path of the destination' do
      it 'returns true' do
        actual = ChessValidator::MoveLogic.collision?('a1', 'a8', ['a4'], 1, 0)
        expect(actual).to eq true
      end
    end
    context 'when there is a piece below in the path of the destination' do
      it 'returns true' do
        actual = ChessValidator::MoveLogic.collision?('b8', 'b1', ['b4'], 1, 0)
        expect(actual).to eq true
      end
    end

    context 'when there is no piece in the path of the destination' do
      it 'returns false' do
        actual = ChessValidator::MoveLogic.collision?('b8', 'b7', ['b4'], 1, 0)
        expect(actual).to eq false
      end
    end
  end

  describe 'horizontal_collision?' do
    context 'when a piece is in the way of the move path from left to right' do
      it 'returns true' do
        occupied_spaces = ['d1']
        expect(ChessValidator::MoveLogic.collision?('a1', 'e1', occupied_spaces, 0, 1)).to be true
      end
    end
    context 'when a piece is in the way of the move path from right to left' do
      it 'returns true' do
        occupied_spaces = ['d1']
        expect(ChessValidator::MoveLogic.collision?('e1', 'a1', occupied_spaces, 0, 1)).to be true
      end
    end

    context 'when a piece is not in the way of another' do
      it 'returns false' do
        occupied_spaces = ['d1']
        expect(ChessValidator::MoveLogic.collision?('f1', 'e1', occupied_spaces, 0, 1)).to be false
      end
    end
  end

  describe 'diagonal_collision?' do
    context 'when there is a diagonal collision' do
      it 'returns true' do
        expect(ChessValidator::MoveLogic.diagonal_collision?('e3', 'a7', ['b6'])).to be true
        expect(ChessValidator::MoveLogic.diagonal_collision?('e3', 'h6', ['g5'])).to be true
        expect(ChessValidator::MoveLogic.diagonal_collision?('e3', 'c1', ['d2'])).to be true
        expect(ChessValidator::MoveLogic.diagonal_collision?('e3', 'g1', ['f2'])).to be true
      end
    end

    context 'when there is not a diagonal collision' do
      it 'returns true' do
        expect(ChessValidator::MoveLogic.diagonal_collision?('e3', 'a1', [])).to be false
        expect(ChessValidator::MoveLogic.diagonal_collision?('e3', 'f6', ['e6'])).to be false
        expect(ChessValidator::MoveLogic.diagonal_collision?('e3', 'b4', ['b4'])).to be false
      end
    end
  end

  describe 'valid_move_path?' do
    context 'when the move path is valid for a vertical move' do
      it 'returns true' do
        piece = ChessValidator::Piece.new('R', 41)

        expect(ChessValidator::MoveLogic.valid_move_path?(piece, 'a7', ['a8', 'a2'])).to be true
      end

      it 'returns true' do
        piece = ChessValidator::Piece.new('R', 9)
        expect(ChessValidator::MoveLogic.valid_move_path?(piece, 'a3', ['a8', 'a2'])).to be true
      end
    end

    context 'when the move path not is valid for a vertical move' do
      it 'returns false' do
        piece = ChessValidator::Piece.new('R', 41)
        expect(ChessValidator::MoveLogic.valid_move_path?(piece, 'a7', ['a8', 'a2', 'a5'])).to be false
      end

      it 'returns false' do
        piece = ChessValidator::Piece.new('R', 9)
        expect(ChessValidator::MoveLogic.valid_move_path?(piece, 'a3', ['a8', 'a2', 'a5'])).to be false
      end
    end

    context 'when the move path is valid for a horizontal move' do
      it 'returns true' do
        piece = ChessValidator::Piece.new('R', 41)
        expect(ChessValidator::MoveLogic.valid_move_path?(piece, 'e3', ['a8', 'a2'])).to be true
      end

      it 'returns true' do
        piece = ChessValidator::Piece.new('R', 13)
        expect(ChessValidator::MoveLogic.valid_move_path?(piece, 'a7', ['a8', 'a2'])).to be true
      end
    end

    context 'when the move path not is valid for a vertical move' do
      it 'returns false' do
        piece = ChessValidator::Piece.new('R', 41)
        expect(ChessValidator::MoveLogic.valid_move_path?(piece, 'e3', ['a8', 'c3', 'a5'])).to be false
      end
    end

    context 'when the move path is valid for a diagonal move' do
      it 'returns true' do
        piece = ChessValidator::Piece.new('B', 36)
        expect(ChessValidator::MoveLogic.valid_move_path?(piece, 'f6', ['a8', 'a2'])).to be true
      end

      it 'returns true' do
        piece = ChessValidator::Piece.new('R', 22)
        expect(ChessValidator::MoveLogic.valid_move_path?(piece, 'd4', ['a8', 'a2'])).to be true
      end

      it 'returns true' do
        piece = ChessValidator::Piece.new('B', 46)
        expect(ChessValidator::MoveLogic.valid_move_path?(piece, 'd5', ['a8', 'a2'])).to be true
      end

      it 'returns true' do
        piece = ChessValidator::Piece.new('R', 28)
        expect(ChessValidator::MoveLogic.valid_move_path?(piece, 'f3', ['a8', 'a2'])).to be true
      end
    end

    context 'when the move path not is valid for a diagonal move' do
      it 'returns false' do
        piece = ChessValidator::Piece.new('R', 46)
        expect(ChessValidator::MoveLogic.valid_move_path?(piece, 'd5', ['a8', 'e4', 'a5'])).to be false
      end

      it 'returns false' do
        piece = ChessValidator::Piece.new('R', 41)
        expect(ChessValidator::MoveLogic.valid_move_path?(piece, 'e7', ['a8', 'd6', 'a5'])).to be false
      end
    end

    context 'when the piece is a knight or a king' do
      it 'returns true' do
        piece = ChessValidator::Piece.new('N', 46)
        expect(ChessValidator::MoveLogic.valid_move_path?(piece, 'd4', ['a8', 'e4', 'a5'])).to be true
      end

      it 'returns false' do
        piece = ChessValidator::Piece.new('R', 41)
        expect(ChessValidator::MoveLogic.valid_move_path?(piece, 'a4', ['a8', 'd6', 'a5'])).to be true
      end
    end
  end

  describe 'valid_destination' do
    context 'when the destination is a different color than the piece moving' do
      it 'returns true' do
        piece = ChessValidator::Piece.new('R', 41)
        enemy_piece = ChessValidator::Piece.new('r', 33)
        board = {33 => enemy_piece, 41 => piece }
        expect(ChessValidator::MoveLogic.valid_destination?(piece, board, 'a4')).to be true
      end
    end

    context 'when the destination is empty' do
      it 'returns true' do
        piece = ChessValidator::Piece.new('R', 41)
        board = { 41 => piece }
        expect(ChessValidator::MoveLogic.valid_destination?(piece, board, 'a4')).to be true
      end
    end

    context 'when the destination is occupied by an allied piece' do
      it 'returns false' do
        piece = ChessValidator::Piece.new('R', 41)
        ally_piece = ChessValidator::Piece.new('R', 33)
        board = {33 => ally_piece, 41 => piece }
        expect(ChessValidator::MoveLogic.valid_destination?(piece, board, 'a4')).to be false
      end
    end
  end

  describe 'advance_pawn' do
    context 'when the pawn advances one sqare forward' do
      context 'when the square is empty' do
        it 'returns true' do
          pawn = ChessValidator::Piece.new('P', 52)
          board = { 52 => pawn }
          expect(ChessValidator::MoveLogic.advance_pawn?(pawn, board, 'd3')).to be true
        end
      end
      context 'when the square is not empty' do
        it 'returns false' do
          pawn = ChessValidator::Piece.new('P', 52)
          rook = ChessValidator::Piece.new('r', 44)
          board = { 52 => pawn, 44 => rook }
          expect(ChessValidator::MoveLogic.advance_pawn?(pawn, board, 'd3')).to be false
        end
      end
    end

    context 'when the pawn advances advances two squares forward' do
      context 'when the square is empty' do
        it 'returns true' do
          pawn = ChessValidator::Piece.new('P', 52)
          board = { 52 => pawn }
          expect(ChessValidator::MoveLogic.advance_pawn?(pawn, board, 'd4')).to be true
        end
      end
      context 'when the square is not empty' do
        it 'returns false' do
          pawn = ChessValidator::Piece.new('P', 52)
          rook = ChessValidator::Piece.new('r', 36)
          board = { 52 => pawn, 44 => rook }
          expect(ChessValidator::MoveLogic.advance_pawn?(pawn, board, 'd4')).to be false
        end
      end
    end

    context 'when the pawn advances advances two squares but their is a piece in the path' do
      it 'returns false' do
        pawn = ChessValidator::Piece.new('P', 52)
        rook = ChessValidator::Piece.new('r', 44)
        board = { 52 => pawn, 44 => rook }
        expect(ChessValidator::MoveLogic.advance_pawn?(pawn, board, 'd4')).to be false
      end
    end
  end

  describe 'handle_pawn' do
    context 'when the pawn is advancing' do
      it 'calls advance_pawn' do
        pawn = ChessValidator::Piece.new('P', 52)
        board = { 52 => pawn }
        fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

        expect(ChessValidator::MoveLogic).to receive(:advance_pawn?).with(pawn, board, 'd4')

        ChessValidator::MoveLogic.handle_pawn(pawn, board, 'd4', fen)
      end
    end

    context 'when the pawn is not advancing' do
      context 'when there is an enemy piece on the square to capture' do
        it 'returns true' do
          pawn = ChessValidator::Piece.new('P', 52)
          enemy_piece = ChessValidator::Piece.new('q', 43)
          board = { 52 => pawn, 43 => enemy_piece }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_pawn(pawn, board, 'c3', fen)).to be true
        end
      end

      context 'when there is an ally piece on the square' do
        it 'returns false' do
          pawn = ChessValidator::Piece.new('P', 52)
          ally_piece = ChessValidator::Piece.new('Q', 43)
          board = { 52 => pawn, 43 => ally_piece }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_pawn(pawn, board, 'c3', fen)).to be false
        end
      end

      context 'when there is an opportunity to en_passant' do
        it 'returns true' do
          pawn = ChessValidator::Piece.new('P', 28)
          enemy_pawn = ChessValidator::Piece.new('p', 29)
          board = { 28 => pawn, 29 => enemy_pawn }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq e6 0 1')

          expect(ChessValidator::MoveLogic.handle_pawn(pawn, board, 'e6', fen)).to be true
        end
      end

      context 'when there is neither a piece nor an opportunity to en_passant' do
        it 'returns false' do
          pawn = ChessValidator::Piece.new('P', 52)
          board = { 52 => pawn }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_pawn(pawn, board, 'c3', fen)).to be false
        end
      end
    end
  end

  describe 'handle_king' do
    context 'when the king has moved two' do
      context 'when there are no enemy pieces attacking the king or the through check position' do
        it 'returns true' do
          king = ChessValidator::Piece.new('K', 61)
          board = { 61 => king }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c1', fen, ['e1'])).to be true
        end
      end

      context 'when there are enemy pieces attacking the king' do
        it 'returns false' do
          king = ChessValidator::Piece.new('K', 61)
          bishop = ChessValidator::Piece.new('b', 47)
          board = { 61 => king, 47 => bishop }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c1', fen, ['e1', 'g3'])).to be false
        end
      end

      context 'when there are enemy pieces attacking the landing square of the king' do
        it 'returns false' do
          king = ChessValidator::Piece.new('K', 61)
          knight = ChessValidator::Piece.new('n', 42)
          board = { 61 => king, 42 => knight }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c1', fen, ['e1', 'b3'])).to be false
        end
      end

      context 'when there are enemy pieces attacking the between check square' do
        it 'returns false' do
          king = ChessValidator::Piece.new('K', 61)
          knight = ChessValidator::Piece.new('n', 43)
          board = { 61 => king, 43 => knight }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c1', fen, ['e1', 'c3'])).to be false
        end
      end

      context 'when the fen notation does not include the castle code' do
        it 'returns false' do
          king = ChessValidator::Piece.new('K', 61)
          board = { 61 => king }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w Kkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c1', fen, ['e1'])).to be false
        end
      end

      context 'when their is a piece on the b square of a queen side castle' do
        it 'returns false' do
          king = ChessValidator::Piece.new('k', 5)
          knight = ChessValidator::Piece.new('n', 2)
          board = { 5 => king, 2 => knight }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w Kkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c8', fen, ['e8', 'b8'])).to be false
        end
      end

      context 'when their is a piece on the b square of a king side castle' do
        it 'returns true' do
          king = ChessValidator::Piece.new('k', 5)
          knight = ChessValidator::Piece.new('n', 2)
          board = { 5 => king, 2 => knight }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w Kkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'g8', fen, ['e8', 'b8'])).to be true
        end
      end

      context 'when their is a piece in the way of the castle' do
        it 'returns false' do
          king = ChessValidator::Piece.new('k', 5)
          rook = ChessValidator::Piece.new('r', 4)
          board = { 5 => king, 4 => rook }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w Kkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c8', fen, ['e8', 'd8'])).to be false
        end
      end

      context 'when their is an enemy piece in the way of the castle' do
        it 'returns false' do
          king = ChessValidator::Piece.new('k', 5)
          knight = ChessValidator::Piece.new('N', 4)
          board = { 5 => king, 4 => knight }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w Kkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c8', fen, ['e8', 'd8'])).to be false
        end
      end

      context 'when their is an enemy piece pinning an ally in front of the king' do
        it 'returns true' do
          king = ChessValidator::Piece.new('k', 5)
          bishop = ChessValidator::Piece.new('B', 26)
          knight = ChessValidator::Piece.new('n', 12)
          board = { 5 => king, 26 => bishop, 12 => knight }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w Kkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c8', fen, ['e8', 'b5', 'd7'])).to be true
        end
      end
    end

    context 'when the king has not moved two' do
      context 'when there are no enemy pieces attacking the king' do
        it 'returns true' do
          king = ChessValidator::Piece.new('K', 35)
          board = { 35 => king }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c5', fen, ['c4'])).to be true
        end
      end

      context 'when there is an enemy pawn attacking the king' do
        it 'returns false' do
          king = ChessValidator::Piece.new('K', 35)
          pawn = ChessValidator::Piece.new('p', 18)
          board = { 35 => king,  18 => pawn }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c5', fen, ['c4', 'b6'])).to be false
        end
      end

      context 'when there is an enemy knight attacking the king' do
        it 'returns false' do
          king = ChessValidator::Piece.new('K', 35)
          knight = ChessValidator::Piece.new('n', 10)
          board = { 35 => king, 10 => knight }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c5', fen, ['c4', 'b7'])).to be false
        end
      end

      context 'when there is an enemy bishop attacking the king' do
        it 'returns false' do
          king = ChessValidator::Piece.new('K', 35)
          bishop = ChessValidator::Piece.new('b', 13)
          board = { 35 => king, 13 => bishop }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c5', fen, ['c4', 'e7'])).to be false
        end
      end

      context 'when there is an enemy rook attacking the king' do
        it 'returns false' do
          king = ChessValidator::Piece.new('K', 35)
          rook = ChessValidator::Piece.new('r', 31)
          board = { 35 => king, 31 => rook }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c5', fen, ['c4', 'g5'])).to be false
        end
      end

      context 'when there is an enemy queen attacking the king' do
        it 'returns false' do
          king = ChessValidator::Piece.new('K', 35)
          queen = ChessValidator::Piece.new('q', 31)
          board = { 35 => king, 31 => queen }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c5', fen, ['c4', 'g5'])).to be false
        end
      end

      context 'when there is an enemy king attacking the king' do
        it 'returns false' do
          king = ChessValidator::Piece.new('K', 35)
          enemy_king = ChessValidator::Piece.new('k', 19)
          board = { 35 => king, 31 => enemy_king }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c5', fen, ['c4', 'g5'])).to be false
        end
      end

      context 'when the square is occupied by an ally' do
        it 'returns false' do
          king = ChessValidator::Piece.new('K', 35)
          ally = ChessValidator::Piece.new('P', 27)
          board = { 35 => king, 27 => ally }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c5', fen, ['c4', 'c5'])).to be false
        end
      end

      context 'when the square is occupied by an enemy' do
        it 'returns true' do
          king = ChessValidator::Piece.new('K', 35)
          enemy = ChessValidator::Piece.new('p', 27)
          board = { 35 => king, 27 => enemy }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c5', fen, ['c4', 'c5'])).to be true
        end
      end

      context 'when the square is occupied by an enemy that is guarded' do
        it 'returns false' do
          king = ChessValidator::Piece.new('K', 35)
          enemy = ChessValidator::Piece.new('p', 27)
          guard = ChessValidator::Piece.new('n', 10)
          board = { 35 => king, 27 => enemy, 10 => guard }
          fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

          expect(ChessValidator::MoveLogic.handle_king(king, board, 'c5', fen, ['c4', 'c5', 'b7'])).to be false
        end
      end
    end
  end

  describe 'valid_move?' do
    context 'when the piece type is k' do
      it 'calls handle_king' do
        king = ChessValidator::Piece.new('K', 35)
        board = { 35 => king }
        fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

        expect(ChessValidator::MoveLogic).to receive(:handle_king)
          .with(king, board, 'f1', fen, ['c4'])

        ChessValidator::MoveLogic.valid_move?(king, board, 'f1', fen)
      end
    end

    context 'when the piece type is p' do
      it 'calls handle_pawn' do
        pawn = ChessValidator::Piece.new('p', 52)
        board = { 52 => pawn }
        fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

        expect(ChessValidator::MoveLogic).to receive(:handle_pawn)
          .with(pawn, board, 'd4', fen)

        ChessValidator::MoveLogic.valid_move?(pawn, board, 'd4', fen)
      end
    end

    context 'when the piece type is not k or p' do
      it 'calls the correct methods' do
        rook = ChessValidator::Piece.new('r', 43)
        board = { 43 => rook }
        occupied_spaces = ['c3']
        fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

        expect(ChessValidator::MoveLogic).to receive(:valid_move_path?)
          .with(rook, 'd3', occupied_spaces).and_return(true)
        expect(ChessValidator::MoveLogic).to receive(:valid_destination?)
          .with(rook, board, 'd3').and_return(true)
        expect(ChessValidator::MoveLogic).to receive(:king_will_be_safe?)
          .with(rook, board, 'd3').and_return(true)

        actual = ChessValidator::MoveLogic.valid_move?(rook, board, 'd3', fen)

        expect(actual).to be true
      end
    end

    context 'when when one of the conditions is not met' do
      it 'returns false' do
        rook = ChessValidator::Piece.new('r', 43)
        board = { 43 => rook }
        occupied_spaces = ['c3']
        fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

        allow(ChessValidator::MoveLogic).to receive(:valid_move_path?)
          .with(rook, 'd3', occupied_spaces).and_return(false)

        actual = ChessValidator::MoveLogic.valid_move?(rook, board, 'd3', fen)

        expect(actual).to be false
      end
    end
  end

  describe 'king_will_be_safe?' do

  end

  describe 'find_next_moves' do

  end

  describe 'load_valid_moves' do

  end
end
