require 'move_logic'
require 'board_logic'
require 'pgn'

RSpec.describe ChessValidator::MoveLogic do
  describe 'next_moves' do
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
          {'a1'=>[]},
          {'b1'=>['a3', 'c3']},
          {'c1'=>[]},
          {'d1'=>[]},
          {'e1'=>[]},
          {'f1'=>[]},
          {'g1'=>['f3', 'h3']},
          {'h1'=>[]}
        ]

        fen = PGN::FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

        actual = ChessValidator::MoveLogic.next_moves(fen).map do |piece|
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
          {'a7'=>[]},
          {'e7'=>['b7', 'c7', 'd7', 'e8', 'f8', 'd6', 'c5', 'f6', 'g5', 'h4']},
          {'f7'=>['f6', 'f5']},
          {'g7'=>['h7', 'f8', 'h8', 'g8']},
          {'a6'=>['a5']},
          {'c6'=>[]},
          {'e6'=>[]},
          {'g6'=>['g5']},
          {'h6'=>['h5']},
          {'b5'=>['a5', 'c5', 'b4', 'b6', 'b7', 'b8']}
        ]

        fen = PGN::FEN.new('2br4/p3qpk1/p1p1p1pp/1rN1P3/1P3P2/2Q1P3/6PP/RR4K1 b - - 4 23')

        actual = ChessValidator::MoveLogic.next_moves(fen).map do |piece|
          { piece.position => piece.valid_moves }
        end

        expect(actual).to eq expected
      end
    end

    context 'when the board is another pattern' do
      it 'returns an array of piece objects with their respective next moves' do
        expected = [
          {'h8'=>['g8', 'g7']},
          {'a7'=>[]},
          {'h7'=>['h6', 'h5']},
          {'a6'=>['b6', 'a3', 'a4', 'a5', 'b7', 'c8', 'b5', 'c4']},
          {'c6'=>['c5']},
          {'d6'=>['e6', 'd4', 'd5', 'd7', 'd8']},
          {'f6'=>['e6', 'f7', 'f8']},
          {'g6'=>['g5']},
          {'f5'=>['f4']},
          {'e4'=>[]},
          {'d3'=>['c4', 'b5', 'c2', 'b1', 'e2', 'f1']}
        ]

        fen = PGN::FEN.new('7k/p6p/q1pr1rp1/4Rp2/1P2p3/P1QbP1PB/5P1P/2R3K1 b - - 3 26')

        actual = ChessValidator::MoveLogic.next_moves(fen).map do |piece|
          { piece.position => piece.valid_moves }
        end

        expect(actual).to eq expected
      end
    end
  end
end
