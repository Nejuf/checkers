class Player

  attr_accessor :color
  def initialize(color)
    @color = color
  end

  def get_formatted_move_sequence
    raise NotImplementedError
  end

end

class HumanPlayer < Player
  def get_formatted_move_sequence
    sequence = []
    begin
      print "\nEnter move sequence: "
      input = gets.chomp.split(%r{\D+})
      input = input.map(&:to_i)
      raise "--Positions must be numeric and in range. (i.e. 1-32)" if input.empty? || input.any? {|el| el < 1 || el > 32}
      raise "--At least two positions are needed to make a move: the position of the piece to move and the destination." if input.length < 2
    rescue StandardError => e
      puts e.message
      retry
    end
    sequence
  end
end

class ComputerPlayer < Player
  def get_formatted_move_sequence
    raise NotImplementedError
  end
end