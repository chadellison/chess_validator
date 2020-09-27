require 'game_logic'

RSpec.describe ChessValidator::GameLogic do
  describe 'find_game_result' do
    it 'calls build_board' do
      fen_notatioin = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
      fen = PGN::FEN.new(fen_notatioin)
      piece = ChessValidator::Piece.new('R', 41)
      board = {41 => piece }

      allow(PGN::FEN).to receive(:new).with(fen_notatioin)
        .and_return(fen)

      expect(ChessValidator::MoveLogic).to receive(:next_moves)
        .with(fen)
        .and_return([])

      expect(ChessValidator::BoardLogic).to receive(:build_board)
        .with(fen)
        .and_return(board)

      expect(ChessValidator::GameLogic).to receive(:checkmate_value)
        .with(fen, board, true)
        .and_return(nil)

      expect(ChessValidator::GameLogic).to receive(:draw?)
        .with(fen, board, true)

      ChessValidator::GameLogic.find_game_result(fen_notatioin)
    end

    describe 'when the checkmate_result is present' do
      it 'returns the checkmate_value' do
        fen_notatioin = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
        fen = PGN::FEN.new(fen_notatioin)
        piece = ChessValidator::Piece.new('R', 41)
        board = {41 => piece }
        expected = '1-0'

        allow(PGN::FEN).to receive(:new).with(fen_notatioin)
          .and_return(fen)

        allow(ChessValidator::MoveLogic).to receive(:next_moves).with(fen)
          .and_return([])

        allow(ChessValidator::BoardLogic).to receive(:build_board)
          .with(fen)
          .and_return(board)

        allow(ChessValidator::GameLogic).to receive(:checkmate_value)
          .with(fen, board, true)
          .and_return(expected)

        actual = ChessValidator::GameLogic.find_game_result(fen_notatioin)

        expect(actual).to eq expected
      end
    end

    describe 'when the checkmate_result is not present and halfmove is 50' do
      it 'returns the draw value' do
        fen_notatioin = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 50 51'
        fen = PGN::FEN.new(fen_notatioin)
        piece = ChessValidator::Piece.new('R', 41)
        board = {41 => piece }
        expected = '1/2-1/2'

        allow(PGN::FEN).to receive(:new).with(fen_notatioin)
          .and_return(fen)

        allow(ChessValidator::MoveLogic).to receive(:next_moves).with(fen)
          .and_return([])

        allow(ChessValidator::BoardLogic).to receive(:build_board)
          .with(fen)
          .and_return(board)

        allow(ChessValidator::GameLogic).to receive(:checkmate_value)
          .with(fen, board, true)
          .and_return(nil)

        actual = ChessValidator::GameLogic.find_game_result(fen_notatioin)

        expect(actual).to eq expected
      end
    end

    describe 'when the checkmate_result is not present and halfmove is not 50' do
      it 'returns nil' do
        fen_notatioin = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
        fen = PGN::FEN.new(fen_notatioin)
        piece = ChessValidator::Piece.new('R', 41)
        board = {41 => piece }

        allow(PGN::FEN).to receive(:new).with(fen_notatioin)
          .and_return(fen)

        allow(ChessValidator::MoveLogic).to receive(:next_moves).with(fen)
          .and_return([])

        allow(ChessValidator::BoardLogic).to receive(:build_board)
          .with(fen)
          .and_return(board)

        allow(ChessValidator::GameLogic).to receive(:checkmate_value)
          .with(fen, board, true)
          .and_return(nil)

        allow(ChessValidator::GameLogic).to receive(:draw?)
          .with(fen, board, true)
          .and_return(false)

        actual = ChessValidator::GameLogic.find_game_result(fen_notatioin)

        expect(actual).to be_nil
      end
    end
  end

  describe 'checkmate_value' do
    describe 'when no moves is true and in_check are both true' do
      it 'returns the checkmate_value' do
        fen_notatioin = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
        fen = PGN::FEN.new(fen_notatioin)
        piece = ChessValidator::Piece.new('K', 41)
        board = {41 => piece }
        occupied_spaces = ['a5']
        expected = '0-1'

        expect(ChessValidator::MoveLogic).to receive(:find_king_and_spaces)
          .with(board, 'w')
          .and_return([piece, occupied_spaces])

        expect(ChessValidator::MoveLogic).to receive(:king_is_safe?)
          .with('w', board, 'a3', occupied_spaces)
          .and_return(false)

        actual = ChessValidator::GameLogic.checkmate_value(fen, board, true)

        expect(actual).to eq expected
      end
    end

    describe 'when no moves is true and in_check are not both true' do
      it 'returns nil' do
        fen_notatioin = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
        fen = PGN::FEN.new(fen_notatioin)
        piece = ChessValidator::Piece.new('K', 41)
        board = {41 => piece }
        occupied_spaces = ['a5']

        expect(ChessValidator::MoveLogic).to receive(:find_king_and_spaces)
          .with(board, 'w')
          .and_return([piece, occupied_spaces])

        expect(ChessValidator::MoveLogic).to receive(:king_is_safe?)
          .with('w', board, 'a3', occupied_spaces)
          .and_return(true)

        actual = ChessValidator::GameLogic.checkmate_value(fen, board, true)

        expect(actual).to be_nil
      end
    end
  end

  describe 'draw' do
    describe 'when the halfmove is 50' do
      it 'returns true' do
        fen_notatioin = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 50 51'
        fen = PGN::FEN.new(fen_notatioin)
        piece = ChessValidator::Piece.new('K', 41)
        board = {41 => piece }
        actual = ChessValidator::GameLogic.draw?(fen, board, false)

        expect(actual).to be true
      end
    end

    describe 'when no_moves is true' do
      it 'returns true' do
        fen_notatioin = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
        fen = PGN::FEN.new(fen_notatioin)
        piece = ChessValidator::Piece.new('K', 41)
        board = {41 => piece }

        expect(ChessValidator::GameLogic).to receive(:insufficient_material?)
          .with(board)
          .and_return(false)

        actual = ChessValidator::GameLogic.draw?(fen, board, true)

        expect(actual).to be true
      end
    end

    describe 'when insufficient_material is true' do
      it 'returns true' do
        fen_notatioin = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
        fen = PGN::FEN.new(fen_notatioin)
        piece = ChessValidator::Piece.new('K', 41)
        board = {41 => piece }

        expect(ChessValidator::GameLogic).to receive(:insufficient_material?)
          .with(board)
          .and_return(true)

        actual = ChessValidator::GameLogic.draw?(fen, board, false)

        expect(actual).to be true
      end
    end

    describe 'when halmove is less than 50, no_moves is false and insufficient_material is false' do
      it 'returns true' do
        fen_notatioin = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
        fen = PGN::FEN.new(fen_notatioin)
        piece = ChessValidator::Piece.new('K', 41)
        board = {41 => piece }

        expect(ChessValidator::GameLogic).to receive(:insufficient_material?)
          .with(board)
          .and_return(false)

        actual = ChessValidator::GameLogic.draw?(fen, board, false)

        expect(actual).to be false
      end
    end

    describe 'insufficient_material?' do
      describe 'when the board size is not less than 4' do
        it 'returns nil' do
          king = ChessValidator::Piece.new('K', 41)
          queen = ChessValidator::Piece.new('Q', 42)
          bishop = ChessValidator::Piece.new('B', 43)
          rook = ChessValidator::Piece.new('R', 44)
          board = {41 => king, 42 => queen, 43 => bishop, 44 => rook}

          actual = ChessValidator::GameLogic.insufficient_material?(board)

          expect(actual).to be_nil
        end
      end

      describe 'when the board size is less than 4 and their is a rook, pawn, or queen present' do
        it 'returns false' do
          king = ChessValidator::Piece.new('K', 41)
          black_king = ChessValidator::Piece.new('k', 3)

          queen = ChessValidator::Piece.new('Q', 42)
          pawn = ChessValidator::Piece.new('P', 43)
          rook = ChessValidator::Piece.new('R', 44)

          board = {41 => king, 3 => black_king, 5 => [queen, pawn, rook].sample}

          actual = ChessValidator::GameLogic.insufficient_material?(board)

          expect(actual).to be false
        end
      end

      describe 'when the board size is less than 4 and their is no rook, pawn, or queen present' do
        it 'returns false' do
          king = ChessValidator::Piece.new('K', 41)
          black_king = ChessValidator::Piece.new('k', 3)

          bishop = ChessValidator::Piece.new('B', 42)
          knight = ChessValidator::Piece.new('N', 43)

          board = {41 => king, 3 => black_king, 5 => [knight, bishop].sample}

          actual = ChessValidator::GameLogic.insufficient_material?(board)

          expect(actual).to be true
        end
      end
    end
  end
end
