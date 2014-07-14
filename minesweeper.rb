#encoding: UTF-8
require 'yaml'

class Minesweeper

  NEIGHBORS = [ [-1,1],
                [-1,0],
                [-1,-1],
                [0,1],
                [0,-1],
                [1,1],
                [1,0],
                [1,-1] ]

  def self.load(file)
    YAML::load(File.open("#{file}.sweep")).play
  end

  def self.make_board(size)
    Array.new(size){Array.new(size, 0)}
  end

  def initialize(bomb_count = 10, size = 9)
    @board = self.class.make_board(size)
    @bomb_positions = []
    @coord_set = build_coord_set(size).sort
    place_bombs(bomb_count)
    set_frontier

    @visible = []
    @flagged = []
  end

  attr_reader :bomb_positions, :coord_set, :visible, :flagged, :board

  def play
    puts "To save your game type 'save', or 'load' to load a previous game"

    while player_moves?
      render
      puts "type 'flag' to plant a flag, otherwise type coords."
      input = gets.chomp.downcase
      if input == 'save'
        return save_game
      end
      request_pos(input)
    end

    if player_wins?
      puts "Player wins!"
    else
      puts "You picked a bomb, you lose!"
    end

    @visible += @bomb_positions
    render
  end

  def request_pos(input)
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

  def save_game
    puts "what do you want to call your game?"
    game_name = gets.chomp
    File.open("#{game_name}.sweep", 'w') { |f| f.write(self.to_yaml) }
    puts "Game saved!"
  end

  # def load_game(file)
  #
  #   @coord_set = g.coord_set
  #   @bomb_positions = g.bomb_positions
  #   @visible = g.visible
  #   @board = g.board
  #   @flagged = g.flagged
  # end

  def plant_flag
    puts "Ok, please input coords for the flag (csv please)."
    flag = convert_str_coords(gets.chomp)
    @flagged.include?(flag) ? @flagged.delete(flag) : @flagged << flag
  end

  def convert_str_coords(pos_str)
    pos_str.split(',').map(&:to_i)
  end

  def player_moves?
    !(player_wins? || player_loses?)
  end

  def player_loses?
    @bomb_positions - @visible != @bomb_positions
  end

  def player_wins?
    (@coord_set - @visible - @bomb_positions).empty?
  end

  def build_coord_set(size)
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
      self[[i,j]] = :*
      @bomb_positions << [i,j]
      @bomb_positions.uniq
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
        self[neighbor] += 1 unless self[neighbor] == :*
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
    top_spacer = "\n\t\t    #{(0..@board.size - 1).to_a.join("  ")}  "
    puts "#{top_spacer}\n"
    dashes = "---" * @board.size
    puts "\t\t   #{dashes}"

    @board.size.times do |row|
      print "\t\t#{row} |"
      @board.size.times do |col|
        if @visible.include?([row,col])
          if self[[row,col]] != 0
            print " #{self[[row,col]]} "
          else
            print "   "
          end
        elsif @flagged.include?([row,col]) && player_moves?
          print " ⚑ "
        else
          print " ❒ "
        end

      end
      print "|\n"
    end
    puts "\t\t   #{dashes}";
    puts "\n\n"
  end

end

if __FILE__ == $PROGRAM_NAME
  file = ARGV.shift
  Minesweeper.load(file) if file
  game = Minesweeper.new
  game.play
end
