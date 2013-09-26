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
        @player1 = HumanPlayer.new
      else if gets.chom.upcase == "N"
        @player1 = ComputerPlayer.new
      end
    end
    while @player2.nil?
      puts "Black player is human? (Y/N)"
      if gets.chomp.upcase == "Y"
        @player2 = HumanPlayer.new
      else if gets.chom.upcase == "N"
        @player2 = ComputerPlayer.new
      end
    end


    until @board.game_over?
      @board.
    end

    puts "Game Over."
  end
end