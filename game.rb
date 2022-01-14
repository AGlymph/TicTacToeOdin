# constants used
module GameConstants
  CELL_ARRAY = [
    [0, 0], [0, 1], [0, 2],
    [1, 0], [1, 1], [1, 2],
    [2, 0], [2, 1], [2, 2]
  ]

  WINNING_SEQ = [
    [1, 2, 3], [4, 5, 6], [7, 8, 9],
    [1, 4, 7], [2, 5, 8], [3, 6, 9],
    [1, 5, 9], [7, 5, 3]
  ]
end

# module to get selections from the player
module InputHandler
  def get_cell_input(player)
    valid_input = false
    cell = 0
    until valid_input
      puts "\nPlayer, #{player.symbol} : Enter cell 1 -> 9"
      cell = gets.chomp.to_i
      if (1..9).include?(cell)
        board.cell_available(cell) ? valid_input = true : (puts 'Cell not available, please try again')
      else
        puts 'Choose value 1 -> 9, please try again.'
      end
    end
    cell
  end
end

# holds state and modifies the game board
class GameBoard
  include GameConstants
  attr_reader :board_data, :cells

  def initialize
    @board_data = Array.new(3) { Array.new(3) }
    i = 0
    @board_data.each { |row| row.map! { |_col| _col = (i += 1) } }
  end

  def display_board
    puts ' '
    @board_data.each { |row| puts row.join('|') }
  end

  def change_cell_to_index(cell)
    index = cell - 1
    row = GameConstants::CELL_ARRAY[index][0]
    col = GameConstants::CELL_ARRAY[index][1]
    [row, col]
  end

  def player_selected(cell, symbol)
    index = change_cell_to_index(cell)
    @board_data[index[0]][index[1]] = symbol
  end

  def cell_available(cell)
    index = change_cell_to_index(cell)
    @board_data[index[0]][index[1]] == cell
  end
end

# class to hold symbol and history of player choices
class Player
  attr_reader :player_cells, :symbol

  def initialize(symbol)
    @symbol = symbol
    @player_cells = []
  end

  def guessed(cell)
    player_cells.push(cell)
  end
end

# keeps tracks of players and board
# notifies game when the game is over
class TicTacToeManager
  include GameConstants
  include InputHandler
  attr_reader :board, :player_one, :player_two

  def initialize
    @board = GameBoard.new
    @player_one = Player.new('X')
    @player_two = Player.new('0')
    @guess_count = 0
  end

  def do_turn(player)
    get_cell(player)
    board.display_board
    game_finished?(player)
  end

  def get_cell(player)
    cell = get_cell_input(player)
    player.guessed(cell)
    @board.player_selected(cell, player.symbol)
  end

  def check_for_win(player)
    player_combos = player.player_cells.combination(3).to_a
    (player_combos.any? { |combo| GameConstants::WINNING_SEQ.include?(combo) })
  end

  def no_more_turns
    @guess_count += 1
    @guess_count >= 9
  end

  def game_finished?(player)
    check_for_win(player) || no_more_turns
  end
end

# class to hold the game loop
class Game
  def play_game
    game_over = false
    @game_manager = TicTacToeManager.new
    @game_manager.board.display_board
    until game_over
      game_over = @game_manager.do_turn(@game_manager.player_one)
      break if game_over

      game_over = @game_manager.do_turn(@game_manager.player_two)
    end
  end
end

# main function to create new game and cloase game
game = Game.new
close_game = false
until close_game
  game.play_game

  valid_input = false
  answer = nil
  until valid_input
    puts "\nGAME OVER!"
    puts "\nPlay Again: Y/N  ?"
    answer = gets.chomp.upcase
    %w[Y N].include?(answer) ? valid_input = true : (puts 'Type Y/y or N/n')
  end
  close_game = (answer == 'N')
end

puts 'THANKS FOR PLAYING'
