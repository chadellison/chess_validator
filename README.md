# chess_validator

A ruby library for validating chess moves and finding the next available moves from a given position.

### Use
find next moves from an fen notation string
```
ChessValidator::Engine.find_next_moves('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
```
returns an array of pieces with their respective next moves
```
# =>
[#<ChessValidator::Piece:0x00007ff81117ac30
  @color="w",
  @enemy_targets=[],
  @piece_type="P",
  @position="a2",
  @square_index=49,
  @valid_moves=["a3", "a4"]>,
 #<ChessValidator::Piece:0x00007ff81117aa78
  @color="w",
  @enemy_targets=[],
  @piece_type="P",
  @position="b2",
  @square_index=50,
  @valid_moves=["b3", "b4"]>,
  ...]
```
or

find next moves from game moves:
```
ChessValidator::Engine.find_next_moves_from_moves(['d4', 'd5', 'Nc3'])
```
returns an array of pieces with their respective next moves
```
# =>
[#<ChessValidator::Piece:0x00007ff8111ca140
  @color="b",
  @enemy_targets=[],
  @piece_type="n",
  @position="b8",
  @square_index=2,
  @valid_moves=["d7", "a6", "c6"]>,
 #<ChessValidator::Piece:0x00007ff8111c9ec0
  @color="b",
  @enemy_targets=[],
  @piece_type="b",
  @position="c8",
  @square_index=3,
  @valid_moves=["d7", "e6", "f5", "g4", "h3"]>,
  ...]
```

```
fen_notation = 'rnbqkbnr/ppp1pppp/8/3p4/3P4/2N5/PPP1PPPP/R1BQKBNR b KQkq - 1 2'
pieces_with_moves = ChessValidator::Engine.find_next_moves_from_moves(['d4', 'd5', 'Nc3'])

ChessValidator::Engine.make_random_move(fen_notation, pieces_with_moves)
```
returns a new fen notation string with the random move applied
```
# => "rnbqkbnr/ppp1pp1p/6p1/3p4/3P4/2N5/PPP1PPPP/R1BQKBNR w KQkq - 2 3"
```
```
piece = pieces_with_moves.first
move = 'c6'
fen_notation = 'rnbqkbnr/ppp1pppp/8/3p4/3P4/2N5/PPP1PPPP/R1BQKBNR b KQkq - 1 2'
ChessValidator::Engine.move(piece, move, fen_notation)
```
returns a new fen notation string with the applied move
```
# => "r1bqkbnr/ppp1pppp/2n5/3p4/3P4/2N5/PPP1PPPP/R1BQKBNR w KQkq - 2 3"
```
```
ChessValidator::Engine.pieces(fen_notation)
```
returns an array of piece objects
```
# =>
[#<ChessValidator::Piece:0x00007ff8111a1060
  @color="b",
  @enemy_targets=[],
  @piece_type="r",
  @position="a8",
  @square_index=1,
  @valid_moves=[]>,
  #<ChessValidator::Piece:0x00007ff8111a0ea8
  @color="b",
  @enemy_targets=[],
  @piece_type="n",
  @position="b8",
  @square_index=2,
  @valid_moves=[]>,
...]
```
```
ChessValidator::Engine.result(fen_notation)
```
returns the game result if one is present


ruby version 2.7.1

run tests with ```rspec```
