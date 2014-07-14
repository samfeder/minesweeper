require 'set'

class Minesweeper
  NEIGHBORS = [ [-1,1],
                [-1,0],
                [-1,-1],
                [0,1],
                [0,-1],
                [1,1],
                [1,0],
                [1,-1] ]

  def self.make_board(size)
    Array.new(size){Array.new(size, 0)}
  end

  def initialize(bomb_count = 10, size = 9)
    @board = self.class.make_board(size)
    @bomb_positions = Set.new
    @coord_set = coord_set(size).sort
    place_bombs(bomb_count)
    set_frontier
    play
  end

  def play
    @visible = []
    @flagged = []
    while player_moves?
      pos = request_pos
      handle(pos)
    end

    if player_wins?
      puts "Player wins!"
    else
      puts "You picked a bomb, you lose!"
    end

    @visible = @coord_set
    render

  end

  def request_pos

  end

  def handle(pos)

  end

  def player_moves?
    !(player_wins? || player_loses?)
  end

  def player_loses?
    if @bomb_positions - @visible != @bomb_positions
      puts "ya lost!"
      true
    end
  end

  def player_wins?
    if !(@coord_set - @visible - @bomb_positions).empty?
      puts "you win!"
      true
    end
  end

  def coord_set(size)
    [].tap do |coords|
      size.times do |row|
        size.times do |col|
          coords << [row, col]
        end
      end
    end
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

  def secret_render
    @board.each do |row|
      puts "\t#{row}"
    end
  end

  def render
    @board.size.times do |row|
      row.size.times do |col|

        if @visible.include?([row,col])
          if self[[row,col]] != 0
            print " #{self[[row,col]]} "
          else
            print "   "
          end
        elsif @flags.include([row,col])
          print " F "
        else
          print " * "
        end

      end
      print "\n"
    end
  end


end




new_game = Minesweeper.new
new_game.secret_render
new_game.set_frontier
puts "\n\n"
new_game.render