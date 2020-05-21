# chess_validator

A ruby library for validating chess moves and finding the next available moves from a given position.

### Use
find next moves from an fen notation string
```
ChessValidator::MoveLogic.find_next_moves('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
```
```
# => [#<ChessValidator::Piece:0x00007f84a0a7eb40
  @color="w",
  @enemy_targets=[],
  @piece_type="P",
  @position="a2",
  @square_index=49,
  @valid_moves=["a3", "a4"]>,
 #<ChessValidator::Piece:0x00007f84a0a7e988
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
ChessValidator::MoveLogic.find_next_moves_from_moves(['d4', 'd5', 'Nc3'])
```

```
# =>
[#<ChessValidator::Piece:0x00007f84a08ed150
  @color="b",
  @enemy_targets=[],
  @piece_type="r",
  @position="a8",
  @square_index=1,
  @valid_moves=[]>,
 #<ChessValidator::Piece:0x00007f84a08f7290
  @color="b",
  @enemy_targets=[],
  @piece_type="n",
  @position="b8",
  @square_index=2,
  @valid_moves=["d7", "a10", "a6", "c10", "c6"]>,
  ...]
```

ruby version 2.6.5

run tests with ```rspec```
