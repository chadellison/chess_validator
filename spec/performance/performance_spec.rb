require 'engine'
require 'pry'
RSpec.describe ChessValidator::Engine do
  it 'completes a game in less than five seconds' do
    start_time = Time.now
    game_over = false
    fen_notation = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'

    until ChessValidator::Engine.result(fen_notation) do
      pieces_with_moves = ChessValidator::Engine.find_next_moves(fen_notation)
      fen_notation = ChessValidator::Engine.make_random_move(fen_notation, pieces_with_moves)
    end

    expect(Time.now - start_time < 5).to be true
  end
end
