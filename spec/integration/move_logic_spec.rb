require 'move_logic'
require 'board_logic'
require 'pgn'

RSpec.describe ChessValidator::MoveLogic do
  describe 'next_moves' do
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
end
