require 'set'

class Minesweeper
  NEIGHBORS = [
                [-1,1],
                [-1,0],
                [-1,-1],
                [0,1],
                [0,-1],
                [1,1],
                [1,0],
                [1,-1]
              ]

  def self.make_board(size)
    Array.new(size){Array.new(size, 0)}
  end

  def initialize(bomb_count = 10, size = 9)
    @board = self.class.make_board(size)
    @bomb_positions = Set.new
    place_bombs(bomb_count)
  end

  def place_bombs(bomb_count)
    while @bomb_positions.size < bomb_count
      i = rand(0...@board.size)
      j = rand(0...@board.size)
      self[[i,j]] = :b
      @bomb_positions.add([i,j])
    end
  end

  def [](pos) # -> [x,y]
    @board[pos[0]][pos[1]]
  end

  def []=(pos, value) # -> [x,y]
    @board[pos[0]][pos[1]] = value
  end

  def set_frontier
    @bomb_positions.each do |bomb|
      valid_neighbors(bomb).each do |neighbor|
        self[neighbor] += 1 unless self[neighbor] == :b
      end
    end
  end

  def valid_neighbors(pos)
    positions = []
    NEIGHBORS.each do |n|
      positions << combine_pos(pos, n)
    end

    positions.reject { |p| p.max >= @board.size || p.min < 0 }
  end

  def combine_pos(pos1, change)
    [pos1[0] + change[0], pos1[1] +change[1]]
  end

  def render
    @board.each do |row|
      puts "\t#{row}"
    end
  end
end




new_game = Minesweeper.new
new_game.render
new_game.set_frontier
new_game.render