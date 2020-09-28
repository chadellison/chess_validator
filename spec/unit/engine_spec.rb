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

  describe 'move' do
    it 'calls make_move on MoveLogic' do
      piece = ChessValidator::Piece.new('p', 9)
      move = 'a4'
      fen_notation = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'

      expect(ChessValidator::MoveLogic).to receive(:make_move)
        .with(piece, move, fen_notation)

      ChessValidator::Engine.move(piece, move, fen_notation)
    end
  end

  describe 'pieces' do
    it 'calls build_board on BoardLogic' do
      piece = ChessValidator::Piece.new('p', 9)
      fen_notation = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
      fen = PGN::FEN.new(fen_notation)

      allow(PGN::FEN).to receive(:new).with(fen_notation)
        .and_return(fen)

      expect(ChessValidator::BoardLogic).to receive(:build_board)
        .with(fen)
        .and_return({1 => piece})

      actual = ChessValidator::Engine.pieces(fen_notation)
      expect(actual).to eq [piece]
    end
  end

  describe 'result' do
    it 'calls find_game_result on GameLogic' do
      fen_notation = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'

      expect(ChessValidator::GameLogic).to receive(:find_game_result)
        .with(fen_notation)

      actual = ChessValidator::Engine.result(fen_notation)
    end
  end
end
