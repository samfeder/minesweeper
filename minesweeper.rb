class Minesweeper

  def self.make_board(size)
    Array.new(size){Array.new(size)}
  end

  def initialize(bomb_count = 10, size = 9)
    @board = self.class.make_board(size)
    place_bombs(bomb_count)
  end

end

new_game = Minesweeper.new
puts new_game