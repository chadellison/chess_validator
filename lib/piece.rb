require_relative './constants/move_key'

module ChessValidator
  class Piece
    attr_accessor :position, :piece_type, :color, :square_index, :valid_moves, :targets, :move_potential

    def initialize(char, square_index)
      @piece_type = char
      @square_index = square_index
      @color = get_color(char)
      @position = get_position(square_index)
      @valid_moves = []
      @targets = []
      @move_potential = []
    end

    def get_position(square_index)
      SQUARE_KEY[square_index]
    end

    def get_color(char)
      char == char.downcase ? 'b' : 'w'
    end
  end
end
