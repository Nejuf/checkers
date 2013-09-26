require_relative 'errors'
class Board

  def initialize
  end

  def perform_moves(color, move_sequence)
    raise InvalidMoveError if !valid_move_seq?(color, move_sequence)
    perform_moves!(move_sequence)
  end

protected
    def perform_moves!(color, move_sequence)

      move_sequence.each do |move|
        start_pos = move.first
        end_pos = move.last
        if Position.delta(start_pos, end_pos).abs == 1
          perform_slide(color, start_pos, end_pos)
        else
          perform_jump(color, start_pos, end_pos)
        end
        #raise InvalidMoveError if sequence fails
      end
    end

    def perform_slide(color, start_pos, end_pos)
      #piece at start position and piece color matches
      #is able to move to destination
      #no piece currently on destination
    end

    def perform_jump(color, start_pos, end_pos)
      #is able to move to destination
      #no piece currently on destination
      #piece on jumped coordinate and that piece is not same color
    end

    def valid_move_seq?(color, move_sequence)
      begin
        board_copy = self.dup#need deep dup?
        board_copy.perform_moves!(color, move_sequence)
      rescue
        return false
      else
        return true
      end
    end

    def piece_at(pos)
    end

end

class Position

  def initialize(x,y)
    @x = x
    @y = y
  end

  def self.delta(start_pos, end_pos)
    Position.new(end_pos.x-start_pos.x, end_pos.y-start_pos.y)
  end
end