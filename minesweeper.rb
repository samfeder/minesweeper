class Minesweeper

  def self.make_board(size)
    Array.new(size){Array.new(size)}
  end

  def initialize(bomb_count = 10, size = 9)
    @board = self.class.make_board(size)
    place_bombs(bomb_count)
  end

  def place_bombs(bomb_count)
    while count_bombs < bomb_count
      i = rand(0...@board.size)
      j = rand(0...@board.size)
      @board[i][j] = :bomb
    end
  end

  def count_bombs
    bombs = 0
    @board.size.times do |i|
      @board.size.times do |j|
        bombs += 1 if @board[i][j] == :bomb
      end
    end

    bombs
  end

  def render
    @board.each do |row|
      puts "\t#{row}"
    end
  end

end

new_game = Minesweeper.new
new_game.render