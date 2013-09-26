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
      elsif gets.chom.upcase == "N"
        @player1 = ComputerPlayer.new :white
      end
    end
    while @player2.nil?
      puts "Black player is human? (Y/N)"
      if gets.chomp.upcase == "Y"
        @player2 = HumanPlayer.new :black
      elsif gets.chom.upcase == "N"
        @player2 = ComputerPlayer.new :black
      end
    end
    @active_player = @player1

    until @board.game_over?
      moves = @active_player.get_formatted_move_sequence
      begin
        @board.perform_moves(@active_player.color, moves)
      rescue
        raise InvalidMoveError
      else
        @active_player = (@active_player == @player1) ? @player2 : @player1
      end
    end

    puts "Game Over."
  end
end