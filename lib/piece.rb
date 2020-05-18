require_relative './constants/square_key'

module ChessValidator
  class Piece
    attr_reader :position, :piece_type, :color, :square_index

    def initialize(char, square_index)
      @piece_type = char
      @square_index = square_index
      @color = get_color(char)
      @position = get_position(square_index)
      @enemy_targets = []
      @valid_moves = []
    end

    def get_position(square_index)
      SQUARE_KEY[square_index]
    end

    def get_color(char)
      char == char.downcase ? 'b' : 'w'
    end
  end
end
