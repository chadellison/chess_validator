require 'move_logic'
require 'board_logic'
require 'piece'
require 'pgn'
require 'pry'

RSpec.describe ChessValidator::Engine do
  describe 'make_random_move' do
    it 'calls make move with the correct arguments' do
      fen_notatioin = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
      piece = ChessValidator::Piece.new('k', 2)
      piece.valid_moves = ['d4']
      pieces_with_moves = [piece]
      expect(ChessValidator::MoveLogic).to receive(:make_move)
        .with(piece, 'd4', fen_notatioin)

      ChessValidator::Engine.make_random_move(fen_notatioin, pieces_with_moves)
    end
  end

  describe 'find_next_moves' do
    it 'calls next_moves with the fen object' do
      fen_notatioin = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
      fen = PGN::FEN.new(fen_notatioin)
      allow(PGN::FEN).to receive(:new).with(fen_notatioin)
        .and_return(fen)

      expect(ChessValidator::MoveLogic).to receive(:next_moves).with(fen)

      ChessValidator::Engine.find_next_moves(fen_notatioin)
    end
  end

  describe 'find_next_moves_from_moves' do
    it 'calls next_moves with the fen object' do
      moves = ['d3', 'c6', 'e4']
      fen_notatioin = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
      game = PGN::Game.new(moves)

      positions = game.positions
      last_position = game.positions.last

      fen = PGN::FEN.new(fen_notatioin)

      allow(PGN::Game).to receive(:new).with(moves)
        .and_return(game)

      allow(game).to receive(:positions).and_return(positions)
      allow(last_position).to receive(:to_fen).and_return(fen)

      expect(ChessValidator::MoveLogic).to receive(:next_moves).with(fen)

      ChessValidator::Engine.find_next_moves_from_moves(moves)
    end
  end
end
