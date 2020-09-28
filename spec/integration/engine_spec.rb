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

        # fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
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
end
