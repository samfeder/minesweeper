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
  end

  def play
    @visible = []
    @flagged = []
    while player_moves?
      render
      request_pos
    end

    if player_wins?
      puts "Player wins!"
    else
      puts "You picked a bomb, you lose!"
    end

    @visible << @bomb_positions
    render
  end

  def request_pos
    puts "type flag if you'd like to plant a flag, otherwise, type coords."
    input = gets.chomp.downcase
    input == "flag" ? plant_flag : handle_reveal(convert_str_coords(input))
  end

  def handle_reveal(pos)
    @visible << pos
    if self[pos] == 0
      valid_neighbors(pos).each do |n|
        handle_reveal(n) if !@visible.include?(n)
      end
    end
  end

  def plant_flag
    puts "Ok, please input coords for the flag (csv please)."
    @flagged << convert_str_coords(gets.chomp)
  end

  def convert_str_coords(pos_str)
    pos_arr = pos_str.split(',')
    [pos_arr[0].to_i, pos_arr[1].to_i]
  end

  def player_moves?
    !(player_wins? || player_loses?)
  end

  def player_loses?
    @bomb_positions.to_a - @visible != @bomb_positions.to_a
  end

  def player_wins?
    (@coord_set - @visible - @bomb_positions.to_a).empty?
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
    print "\n"
    @board.size.times do |row|
      print "\t\t"
      @board.size.times do |col| #what the fuck?
        if @visible.include?([row,col])
          if self[[row,col]] != 0
            print " #{self[[row,col]]} "
          else
            print "   "
          end
        elsif @flagged.include?([row,col]) && player_moves?
          print " F "
        else
          print " * "
        end

      end
      print "\n"
    end
    print "\n"
  end


end


new_game = Minesweeper.new
new_game.secret_render
new_game.play
new_game.secret_render