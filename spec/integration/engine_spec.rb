require 'engine'

RSpec.describe ChessValidator::Engine do
  describe 'find_next_moves' do
    context 'when there is a new board' do
      it 'returns an array of piece objects with their respective next moves' do
        expected = [
          {'a2'=>['a3', 'a4']},
          {'b2'=>['b3', 'b4']},
          {'c2'=>['c3', 'c4']},
          {'d2'=>['d3', 'd4']},
          {'e2'=>['e3', 'e4']},
          {'f2'=>['f3', 'f4']},
          {'g2'=>['g3', 'g4']},
          {'h2'=>['h3', 'h4']},
          {'b1'=>['a3', 'c3']},
          {'g1'=>['f3', 'h3']},
        ]

        fen_notation = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'

        actual = ChessValidator::Engine.find_next_moves(fen_notation).map do |piece|
          { piece.position => piece.valid_moves }
        end

        expect(actual).to eq expected
      end
    end

    context 'when there is not a new board' do
      it 'returns an array of piece objects with their respective next moves' do
        expected = [
          {'c8'=>['b7', 'd7']},
          {'d8'=>['e8', 'f8', 'g8', 'h8', 'd1', 'd2', 'd3', 'd4', 'd5', 'd6', 'd7']},
          {'e7'=>['b7', 'c7', 'd7', 'e8', 'f8', 'd6', 'c5', 'f6', 'g5', 'h4']},
          {'f7'=>['f6', 'f5']},
          {'g7'=>['h7', 'f8', 'h8', 'g8']},
          {'a6'=>['a5']},
          {'g6'=>['g5']},
          {'h6'=>['h5']},
          {'b5'=>['a5', 'c5', 'b4', 'b6', 'b7', 'b8']}
        ]

        fen_notation = '2br4/p3qpk1/p1p1p1pp/1rN1P3/1P3P2/2Q1P3/6PP/RR4K1 b - - 4 23'

        actual = ChessValidator::Engine.find_next_moves(fen_notation).map do |piece|
          { piece.position => piece.valid_moves }
        end

        expect(actual).to eq expected
      end
    end

    context 'when the board is another pattern' do
      it 'returns an array of piece objects with their respective next moves' do
        expected = [
          {'h8'=>['g8', 'g7']},
          {'h7'=>['h6', 'h5']},
          {'a6'=>['b6', 'a3', 'a4', 'a5', 'b7', 'c8', 'b5', 'c4']},
          {'c6'=>['c5']},
          {'d6'=>['e6', 'd4', 'd5', 'd7', 'd8']},
          {'f6'=>['e6', 'f7', 'f8']},
          {'g6'=>['g5']},
          {'f5'=>['f4']},
          {'d3'=>['c4', 'b5', 'c2', 'b1', 'e2', 'f1']}
        ]

        fen_notation = '7k/p6p/q1pr1rp1/4Rp2/1P2p3/P1QbP1PB/5P1P/2R3K1 b - - 3 26'

        actual = ChessValidator::Engine.find_next_moves(fen_notation).map do |piece|
          { piece.position => piece.valid_moves }
        end

        expect(actual).to eq expected
      end
    end

    context 'when the board is another pattern still' do
      it 'returns an array of piece objects with their respective next moves' do
        expected = [
          {'e4'=>['e5']},
          {'c3'=>['a4', 'b5', 'b1', 'd1']},
          {'e3'=>['f4', 'g5', 'h6', 'd4', 'c5']},
          {'f3'=>['d4', 'h4', 'h2', 'e5', 'e1', 'g5']},
          {'h3'=>['h4']},
          {'a2'=>['a3']},
          {'b2'=>['b3', 'b4']},
          {'d2'=>['c2', 'd1', 'd3', 'd4', 'c1', 'e1']},
          {'e2'=>['d3', 'c4', 'b5', 'a6', 'd1']},
          {'g2'=>['g3', 'g4']},
          {'a1'=>['b1', 'c1', 'd1', 'e1']},
          {'f1'=>['b1', 'c1', 'd1', 'e1']},
          {'g1'=>['h1', 'h2']}
       ]

        fen_notation = 'r1b2r2/4ppbk/p2p1npp/q1pP4/n3P3/2N1BN1P/PP1QBPP1/R4RK1 w - - 2 15'

        actual = ChessValidator::Engine.find_next_moves(fen_notation).map do |piece|
          { piece.position => piece.valid_moves }
        end

        expect(actual).to eq expected
      end
    end
  end

  describe 'find_next_moves_from_moves' do
    it 'returns the correct next moves' do
      expected = [
        {'b8'=>['d7', 'a6', 'c6']},
        {'c8'=>['d7', 'e6', 'f5', 'g4', 'h3']},
        {'d8'=>['d6', 'd7']},
        {'e8'=>['d7']},
        {'g8'=>['f6', 'h6']},
        {'a7'=>['a6', 'a5']},
        {'b7'=>['b6', 'b5']},
        {'c7'=>['c6', 'c5']},
        {'e7'=>['e6', 'e5']},
        {'f7'=>['f6', 'f5']},
        {'g7'=>['g6', 'g5']},
        {'h7'=>['h6', 'h5']},
        {'d5'=>['e4', 'd4']}
     ]

      actual = ChessValidator::Engine.find_next_moves_from_moves(['e4', 'd5', 'c3']).map do |piece|
        { piece.position => piece.valid_moves }
      end

      expect(actual).to eq expected
    end
  end

  describe 'pieces' do
    it 'returns the pieces from the given fen string' do
      expected = [
        {piece_type: 'r', position: 'a8'},
        {piece_type: 'b', position: 'c8'},
        {piece_type: 'r', position: 'f8'},
        {piece_type: 'p', position: 'e7'},
        {piece_type: 'p', position: 'f7'},
        {piece_type: 'b', position: 'g7'},
        {piece_type: 'k', position: 'h7'},
        {piece_type: 'p', position: 'a6'},
        {piece_type: 'p', position: 'd6'},
        {piece_type: 'n', position: 'f6'},
        {piece_type: 'p', position: 'g6'},
        {piece_type: 'p', position: 'h6'},
        {piece_type: 'q', position: 'a5'},
        {piece_type: 'p', position: 'c5'},
        {piece_type: 'P', position: 'd5'},
        {piece_type: 'n', position: 'a4'},
        {piece_type: 'P', position: 'e4'},
        {piece_type: 'N', position: 'c3'},
        {piece_type: 'B', position: 'e3'},
        {piece_type: 'N', position: 'f3'},
        {piece_type: 'P', position: 'h3'},
        {piece_type: 'P', position: 'a2'},
        {piece_type: 'P', position: 'b2'},
        {piece_type: 'Q', position: 'd2'},
        {piece_type: 'B', position: 'e2'},
        {piece_type: 'P', position: 'f2'},
        {piece_type: 'P', position: 'g2'},
        {piece_type: 'R', position: 'a1'},
        {piece_type: 'R', position: 'f1'},
        {piece_type: 'K', position: 'g1'}
      ]

      fen_notation = 'r1b2r2/4ppbk/p2p1npp/q1pP4/n3P3/2N1BN1P/PP1QBPP1/R4RK1 w - - 2 15'

      actual = ChessValidator::Engine.pieces(fen_notation).map do |piece|
        {piece_type: piece.piece_type, position: piece.position }
      end

      expect(actual).to eq expected
    end

    context 'when there are few pieces' do
      it 'returns the pieces from the string' do
        expected = [
          {piece_type: 'k', position: 'e7'},
          {piece_type: 'K', position: 'd3'}
        ]
        fen_notation = '8/4k3/8/8/8/3K4/8/8 w - - 2 100'

        actual = ChessValidator::Engine.pieces(fen_notation).map do |piece|
          {piece_type: piece.piece_type, position: piece.position }
        end

        expect(actual).to eq expected
      end
    end
  end

  describe 'move' do
    it 'returns the new fen notated string' do
      fen_notation = 'rnbqkbnr/ppp1pppp/8/3p4/3P4/2N5/PPP1PPPP/R1BQKBNR b KQkq - 1 2'
      piece = ChessValidator::Piece.new('n', 2)
      move = 'c6'
      expected = 'r1bqkbnr/ppp1pppp/2n5/3p4/3P4/2N5/PPP1PPPP/R1BQKBNR w KQkq - 2 3'

      actual = ChessValidator::Engine.move(piece, move, fen_notation)

      expect(actual).to eq expected
    end
  end

  describe 'result' do
    context 'when it is a draw' do
      it 'returns the result of the game' do
        fen_notation = '8/4k3/8/8/8/3K4/8/8 w - - 2 100'
        expected = '1/2-1/2'

        actual = ChessValidator::Engine.result(fen_notation)

        expect(actual).to eq expected
      end
    end

    context 'when the result is a checkmate' do
      it 'returns the result' do
        expected = '1-0'
        fen_notation = 'r1bqkb1r/ppp1pQpp/2np1n2/8/2BP4/8/PPP1PPPP/RNBQKBNR b KQkq - 5 4'
        fen_notation = 'r1bqkb1r/pppp1Qpp/2n2n2/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 5 4'

        actual = ChessValidator::Engine.result(fen_notation)

        expect(actual).to eq expected
      end
    end

    context 'when there is no result' do
      it 'returns nil' do
        fen_notation = 'rnbqkbnr/ppp1pppp/8/3p4/3P4/2N5/PPP1PPPP/R1BQKBNR b KQkq - 1 2'
        actual = ChessValidator::Engine.result(fen_notation)

        expect(actual).to be_nil
      end
    end
  end
end
