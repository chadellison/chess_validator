require 'move_logic'
require 'piece'

RSpec.describe ChessValidator::MoveLogic do
  describe 'moves_for_rook' do
    it 'returns an array of all possible moves for a rook in a given position' do
      expected = ['d5', 'd6', 'd7', 'd8', 'd3', 'd2', 'd1', 'c4', 'b4', 'a4',
                  'e4', 'f4', 'g4', 'h4']

      expect(ChessValidator::MoveLogic.moves_for_rook('d4')).to eq expected
    end
  end

  describe 'moves_up' do
    it 'returns an array of all possible moves up given a position' do
      expected = ['f4', 'f5', 'f6', 'f7', 'f8']

      expect(ChessValidator::MoveLogic.moves_up('f3')).to eq expected
    end
  end

  describe 'moves_down' do
    it 'returns an array of all possible moves down given a position' do
      expected = ['f2', 'f1']

      expect(ChessValidator::MoveLogic.moves_down('f3')).to eq expected
    end
  end

  describe 'moves_left' do
    it 'returns an array of all possible moves left given a position' do
      expected = ['e3', 'd3', 'c3', 'b3', 'a3']

      expect(ChessValidator::MoveLogic.moves_left('f3')).to eq expected
    end
  end

  describe 'moves_right' do
    it 'returns an array of all possible moves right given a position' do
      expected = ['g3', 'h3']

      expect(ChessValidator::MoveLogic.moves_right('f3')).to eq expected
    end
  end

  describe 'moves_for_bishop' do
    it 'returns an array of all possible moves for a bishop in a given position' do
      expected = ['e5', 'f6', 'g7', 'h8', 'c5', 'b6', 'a7', 'c3', 'b2', 'a1',
                  'e3', 'f2', 'g1']

      expect(ChessValidator::MoveLogic.moves_for_bishop('d4')).to eq expected
    end
  end

  describe 'extract_diagonals' do
    it 'returns an array of each set\'s first coordinate\'s column and second corrdinate\'s row' do
      expect(ChessValidator::MoveLogic.extract_diagonals([['b2', 'a3']])).to eq ['b3']
    end
  end

  describe 'moves_for_queen' do
    it 'returns an array of all possible moves for a queen in a given position' do
      expected = ['d5', 'd6', 'd7', 'd8', 'd3', 'd2', 'd1', 'c4', 'b4', 'a4',
                  'e4', 'f4', 'g4', 'h4', 'e5', 'f6', 'g7', 'h8', 'c5', 'b6',
                  'a7', 'c3', 'b2', 'a1', 'e3', 'f2', 'g1']

      expect(ChessValidator::MoveLogic.moves_for_queen('d4')).to eq expected
    end
  end

  describe 'moves_for_king' do
    it 'returns an array of all possible moves for a king in a given position' do
      expected = ['d5', 'd3', 'c4', 'e4', 'e5', 'c5', 'c3', 'e3', 'b4', 'f4'].sort

      expect(ChessValidator::MoveLogic.moves_for_king('d4').sort).to eq expected
    end
  end

  describe 'moves_for_knight' do
    it 'returns an array of all possible moves for a knight in a given position' do
      expected = ['b5', 'b3', 'f5', 'f3', 'c6', 'c2', 'e6', 'e2']

      expect(ChessValidator::MoveLogic.moves_for_knight('d4')).to eq expected
    end
  end

  describe 'moves_for_pawn' do
    context 'when the pawn is on d4' do
      it 'returns an array of all possible moves for a pawn (of either color) in a given position' do
        piece = ChessValidator::Piece.new('p', 36)
        expected = ["c3", "e3", "d3"]

        expect(ChessValidator::MoveLogic.moves_for_pawn(piece)).to eq expected
      end
    end

    context 'when the pawn is on its starting square' do
      it 'returns an array of all possible moves for a pawn (of either color) in a given position' do
        piece = ChessValidator::Piece.new('P', 52)
        expected = ["c3", "e3", "d3", "d4"]

        expect(ChessValidator::MoveLogic.moves_for_pawn(piece)).to eq expected
      end
    end
  end

  describe 'remove_out_of_bounds_moves' do
    it 'removes coordinates that are greater than 8 and less than 1' do
      actual = ChessValidator::MoveLogic.remove_out_of_bounds_moves(['a0', 'a2', 'a9'])
      expect(actual).to eq ['a2']
    end

    it 'removes coordinates that are greater than h and less than a' do
      actual = ChessValidator::MoveLogic.remove_out_of_bounds_moves(['`0', 'a2', 'i9'])
      expect(actual).to eq ['a2']
    end

    it 'does not remove coordinates that are within bounds' do
      actual = ChessValidator::MoveLogic.remove_out_of_bounds_moves(['a1', 'a2', 'a3'])
      expect(actual).to eq ['a1', 'a2', 'a3']
    end
  end

  describe 'vertical_collision?' do
    context 'when there is a piece above in the path of the destination' do
      it 'returns true' do
        actual = ChessValidator::MoveLogic.vertical_collision?('a1', 'a8', ['a4'])
        expect(actual).to eq true
      end
    end
    context 'when there is a piece below in the path of the destination' do
      it 'returns true' do
        actual = ChessValidator::MoveLogic.vertical_collision?('b8', 'b1', ['b4'])
        expect(actual).to eq true
      end
    end

    context 'when there is no piece in the path of the destination' do
      it 'returns false' do
        actual = ChessValidator::MoveLogic.vertical_collision?('b8', 'b7', ['b4'])
        expect(actual).to eq false
      end
    end
  end

  describe 'horizontal_collision?' do
    context 'when a piece is in the way of the move path from left to right' do
      it 'returns true' do
        occupied_spaces = ['d1']
        expect(ChessValidator::MoveLogic.horizontal_collision?('a1', 'e1', occupied_spaces)).to be true
      end
    end
    context 'when a piece is in the way of the move path from right to left' do
      it 'returns true' do
        occupied_spaces = ['d1']
        expect(ChessValidator::MoveLogic.horizontal_collision?('e1', 'a1', occupied_spaces)).to be true
      end
    end

    context 'when a piece is not in the way of another' do
      it 'returns false' do
        occupied_spaces = ['d1']
        expect(ChessValidator::MoveLogic.horizontal_collision?('f1', 'e1', occupied_spaces)).to be false
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

  # describe 'valid_destination' do
  #   context 'when the destination is a different color than the piece moving' do
  #     let(:game) { Game.create }
  #
  #     it 'returns true' do
  #
  #       white_piece = Piece.new(color: 'white', position: 'a3', piece_type: 'rook', game_id: game.id)
  #
  #       black_piece = Piece.new(color: 'black', position: 'a4', piece_type: 'rook')
  #
  #       game.pieces << white_piece
  #       game.pieces << black_piece
  #
  #       expect(white_piece.valid_destination?('a4', game.pieces)).to be true
  #     end
  #   end
  #
  #   context 'when the destination is empty' do
  #     let(:game) { Game.create }
  #     it 'returns true' do
  #       piece_one = Piece.new(
  #         color: 'white',
  #         position: 'a3',
  #         piece_type: 'rook',
  #         position_index: 25,
  #         game_id: game.id
  #       )
  #       piece_two = Piece.new(
  #         color: 'black',
  #         position: 'a7',
  #         piece_type: 'rook',
  #         position_index: 32,
  #         game_id: game.id
  #       )
  #
  #       game.pieces << piece_one
  #       game.pieces << piece_two
  #
  #       expect(piece_one.valid_destination?('a4', game.pieces)).to be true
  #     end
  #   end
  #
  #   context 'when the destination is occupied by an allied piece' do
  #     let(:game) { Game.create }
  #
  #     it 'returns false' do
  #       piece = game.find_piece_by_index(17)
  #
  #       game_piece = game.find_piece_by_index(9)
  #
  #       game_piece.color = 'white'
  #       game_piece.position = 'a7'
  #       game_piece.piece_type = 'rook'
  #       game_piece.position_index = 32
  #
  #       expect(piece.valid_destination?('a7', game.pieces)).to be false
  #     end
  #   end
  #
  #   context 'when the destination is the opponent king' do
  #     let(:game) {
  #       Game.create
  #     }
  #
  #     it 'returns true' do
  #       piece = game.find_piece_by_index(26)
  #       game.find_piece_by_index(5).position = 'd6'
  #       piece.position = 'e4'
  #
  #       expect(piece.valid_destination?('d6', game.pieces)).to be true
  #     end
  #   end
  # end
  #
  # describe 'king_is_safe?' do
  #   context 'when the king is not in check' do
  #     let(:game) {
  #       Game.create
  #     }
  #
  #     it 'returns true' do
  #       piece = game.find_piece_by_index(25)
  #       piece.position = 'a3'
  #
  #       game.find_piece_by_index(5).position = 'd6'
  #
  #       expect(Piece.king_is_safe?('black', game.pieces)).to be true
  #     end
  #   end
  #
  #   context 'when the king is in check' do
  #     let(:game) { Game.create }
  #
  #     it 'returns false' do
  #       piece = game.find_piece_by_index(25)
  #       piece.position = 'd4'
  #
  #       game.find_piece_by_index(5).position = 'd6'
  #       expect(Piece.king_is_safe?('black', game.pieces)).to be false
  #     end
  #   end
  #
  #   context 'when the king is in check from a diagonal threat' do
  #     let(:game) { Game.create }
  #
  #     it 'returns false' do
  #       piece = game.find_piece_by_index(30)
  #       piece.position = 'h3'
  #
  #       game.find_piece_by_index(5).position = 'e6'
  #       expect(Piece.king_is_safe?('black', game.pieces)).to be false
  #     end
  #   end
  #
  #   context 'when the king is in check from a diagonal one space away' do
  #     let(:game) { Game.create }
  #
  #     it 'returns false' do
  #       piece = game.find_piece_by_index(30)
  #       piece.position = 'f5'
  #
  #       game.find_piece_by_index(5).position = 'e6'
  #       expect(Piece.king_is_safe?('black', game.pieces)).to be false
  #     end
  #   end
  #
  #   context 'when the king is in check from a knight' do
  #     let(:game) { Game.create }
  #
  #     it 'returns false' do
  #       game.find_piece_by_index(2).position = 'f3'
  #
  #       piece = game.pieces.detect { |piece| piece.color == 'white' && piece.piece_type == 'king' }
  #       expect(Piece.king_is_safe?('white', game.pieces)).to be false
  #     end
  #   end
  # end
  #
  # describe 'can_en_pessant?' do
  #   let(:game) { Game.create }
  #   let(:piece) { game.find_piece_by_position('c2') }
  #
  #   context 'when the adjacent peice is an ally' do
  #     before do
  #       ally = game.find_piece_by_position('d2')
  #       ally.position = 'd4'
  #       ally.moved_two = true
  #       piece.position = 'c4'
  #     end
  #
  #     it 'returns false' do
  #       expect(piece.can_en_pessant?('d5', game.pieces)).to be false
  #     end
  #   end
  # end
  #
  # describe 'valid_for_pawn?' do
  #   context 'when the pawn moves one space forward and the space is open' do
  #     let(:game) { Game.create }
  #
  #     it 'returns true' do
  #       piece = game.find_piece_by_position('d2')
  #       expect(piece.valid_for_pawn?('d3', game.pieces)).to be true
  #     end
  #   end
  #
  #   context 'when the pawn moves one space forward and the space is not open' do
  #     let(:game) { Game.create }
  #
  #     before do
  #       game.find_piece_by_position('d2').position = 'd4'
  #       game.find_piece_by_position('d7').position = 'd5'
  #     end
  #
  #     it 'returns false' do
  #       piece = game.find_piece_by_position('d4')
  #       expect(piece.valid_for_pawn?('d5', game.pieces)).to be false
  #     end
  #   end
  #
  #   context 'when the black pawn moves one space forward and the space is open' do
  #     let(:game) { Game.create }
  #
  #     it 'returns true' do
  #       piece = game.find_piece_by_position('d7')
  #       expect(piece.valid_for_pawn?('d6', game.pieces)).to be true
  #     end
  #   end
  #
  #   context 'when the black pawn moves one space forward and the space is not open' do
  #     let(:game) { Game.create }
  #
  #     before do
  #       game.find_piece_by_position('d7').position = 'd5'
  #       game.find_piece_by_position('d2').position = 'd4'
  #     end
  #
  #     it 'returns false' do
  #       piece = game.find_piece_by_position('d5')
  #       expect(piece.valid_for_pawn?('d4', game.pieces)).to be false
  #     end
  #   end
  # end
  #
  # context 'when the pawn moves two spaces forward and the space is open' do
  #   let(:game) { Game.create }
  #
  #   it 'returns false' do
  #     piece = game.find_piece_by_position('d2')
  #     expect(piece.valid_for_pawn?('d4', game.pieces)).to be true
  #   end
  # end
  #
  # context 'when the pawn moves two spaces forward and the space is not open' do
  #   let(:game) { Game.create }
  #
  #   before do
  #     game.pieces.detect { |piece| piece.position == 'd7' }.position = 'd4'
  #   end
  #
  #   it 'returns false' do
  #     piece = game.pieces.detect { |piece| piece.position == 'd2' }
  #     expect(piece.valid_for_pawn?('d4', game.pieces)).to be false
  #   end
  # end
  #
  # context 'when the pawn moves two spaces forward and the pawn has already moved' do
  #   let(:game) { Game.create }
  #
  #   before do
  #     game.find_piece_by_position('d2').has_moved = true
  #   end
  #
  #   it 'returns false' do
  #     piece = game.find_piece_by_position('d2')
  #     expect(piece.valid_for_pawn?('d4', game.pieces)).to be false
  #   end
  # end
  #
  # context 'when the pawn attempts to move in the wrong direction' do
  #   let(:game) { Game.create }
  #
  #   before do
  #     game.pieces.detect { |piece| piece.position == 'd2' }.position = 'd4'
  #   end
  #
  #   it 'returns false' do
  #     piece = game.pieces.detect { |piece| piece.position == 'd4' }
  #     expect(piece.valid_for_pawn?('d3', game.pieces)).to be false
  #   end
  # end
  #
  # context 'when the pawn attempts to capture a piece in the wrong direction' do
  #   let(:game) { Game.create }
  #
  #   before do
  #     game.find_piece_by_position('d2').position = 'd4'
  #     game.find_piece_by_position('e7').position = 'e3'
  #   end
  #
  #   it 'returns false' do
  #     piece = game.find_piece_by_position('d4')
  #     expect(piece.valid_for_pawn?('e3', game.pieces)).to be false
  #   end
  # end
  #
  # context 'when the pawn attempts to capture a piece on an empty square' do
  #   let(:game) { Game.create }
  #
  #   before do
  #     game.find_piece_by_position('d2').position = 'd4'
  #     game.find_piece_by_position('e7').position = 'e5'
  #   end
  #
  #   it 'returns false' do
  #     piece = game.find_piece_by_position('d4')
  #     expect(piece.valid_for_pawn?('c5', game.pieces)).to be false
  #   end
  # end
  #
  # context 'when the pawn attempts to capture a piece on an occupied square' do
  #   let(:game) { Game.create }
  #
  #   before do
  #     game.find_piece_by_position('d2').position = 'd4'
  #     game.find_piece_by_position('e7').position = 'e5'
  #   end
  #
  #   it 'returns true' do
  #     piece = game.find_piece_by_position('d4')
  #     expect(piece.valid_for_pawn?('e5', game.pieces)).to be true
  #   end
  # end
  #
  # context 'when the pawn attempts to en passant a piece correctly' do
  #   let(:game) { Game.create }
  #
  #   before do
  #     game.find_piece_by_position('d2').position = 'd5'
  #     game_piece = game.find_piece_by_position('e7')
  #     game_piece.position = 'e5'
  #     game_piece.moved_two = true
  #   end
  #
  #   it 'returns true' do
  #     piece = game.find_piece_by_position('d5')
  #     expect(piece.valid_for_pawn?('e6', game.pieces)).to be true
  #   end
  # end
  #
  # context 'when the pawn attempts to en passant a piece that has not moved_two' do
  #   let(:game) { Game.create }
  #
  #   before do
  #     game.find_piece_by_position('d2').position = 'd5'
  #     game.find_piece_by_position('e7').position = 'e5'
  #   end
  #
  #   it 'returns false' do
  #     piece = game.find_piece_by_position('d5')
  #     expect(piece.valid_for_pawn?('e6', game.pieces)).to be false
  #   end
  # end
  #
  # context 'when the pawn attempts to en passant in the wrong direction' do
  #   let(:game) { Game.create }
  #
  #   before do
  #     game.find_piece_by_position('d2').position = 'd5'
  #     moved_pawn = game.find_piece_by_position('e7')
  #     moved_pawn.position = 'e5'
  #     moved_pawn.moved_two = true
  #   end
  #
  #   it 'returns false' do
  #     piece = game.find_piece_by_position('d5')
  #     expect(piece.valid_for_pawn?('e4', game.pieces)).to be false
  #   end
  # end
  #
  # describe '#advance_pawn?' do
  #   let(:game) { Game.create }
  #
  #   let(:piece) {
  #     Piece.new(
  #       piece_type: 'pawn',
  #       color: 'white',
  #       position_index: 20,
  #       position: 'd4',
  #       game: game
  #     )
  #   }
  #
  #   context 'when a piece is in the way of the pawn' do
  #     before do
  #       game.pieces.detect { |piece| piece.position == 'd7' }.position = 'd5'
  #     end
  #
  #     it 'returns false' do
  #       expect(piece.advance_pawn?('d5', game.pieces)).to be false
  #     end
  #   end
  #
  #   context 'when a piece is not in the way of the pawn' do
  #     it 'returns true' do
  #       expect(piece.advance_pawn?('d5', game.pieces)).to be true
  #     end
  #   end
  # end
  #
  # describe '#forward_two?' do
  #   context 'when the piece has moved down two' do
  #     it 'returns true' do
  #       piece = Piece.new(position: 'b7')
  #       expect(piece.forward_two?('b5')).to be true
  #     end
  #   end
  #
  #   context 'when the piece has moved up two' do
  #     it 'returns true' do
  #       piece = Piece.new(position: 'a2')
  #       expect(piece.forward_two?('a4')).to be true
  #     end
  #   end
  #
  #   context 'when the piece has not moved down two or up two' do
  #     it 'returns false' do
  #       piece = Piece.new(position: 'a2')
  #       expect(piece.forward_two?('a3')).to be false
  #     end
  #   end
  # end
end
