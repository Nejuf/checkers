require_relative "Board"
require_relative "Player"
require_relative 'errors'

class Checkers

  def initialize
    @board = Board.new
    @active_player = nil
    @player1 = nil
    @player2 = nil
    play
  end

  def play
    @board.setup
    while @player1.nil?
      puts "White player is human? (Y/N)"
      if gets.chomp.upcase == "Y"
        @player1 = HumanPlayer.new :white
      elsif gets.chomp.upcase == "N"
        @player1 = ComputerPlayer.new :white
      end
    end
    while @player2.nil?
      puts "Black player is human? (Y/N)"
      if gets.chomp.upcase == "Y"
        @player2 = HumanPlayer.new :black
      elsif gets.chomp.upcase == "N"
        @player2 = ComputerPlayer.new :black
      end
    end
    @active_player = @player1

    until @board.game_over?(@active_player)
      @board.render
      moves = @active_player.get_formatted_move_sequence
      begin
        @board.perform_moves(@active_player.color, moves)
      rescue InvalidMoveError => e
        puts "\nInvalid move: #{e.message}"
      else
        @active_player = (@active_player == @player1) ? @player2 : @player1
      end
    end
    #The winning player is the one who made the move that triggered game over
    winning_player = (@active_player == @player1) ? @player2 : @player1
    puts "Game Over. #{winning_player.color.capitalize} wins!"
  end
end