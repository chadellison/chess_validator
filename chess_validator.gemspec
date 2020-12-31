Gem::Specification.new 'chess_validator', '1.0' do |s|
  s.name        = 'chess_validator'
  s.version     = '0.2.16'
  s.date        = '2020-11-16'
  s.summary     = "A chess move validator"
  s.description = "Documentation: https://github.com/chadellison/chess_validator"
  s.authors     = ["Charles Ellison"]
  s.homepage    = 'https://rubygems.org/search?utf8=%E2%9C%93&query=chess_validator'
  s.email       = 'chad.ellison0123@gmail.com'
  s.files       = [
                    'lib/chess_validator.rb',
                    'lib/move_logic.rb',
                    'lib/board_logic.rb',
                    'lib/piece.rb',
                    'lib/constants/move_key.rb',
                    'lib/game_logic.rb',
                    'lib/engine.rb'
                  ]
  s.license     = 'MIT'
end
