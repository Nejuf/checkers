require_relative 'errors'
require_relative "Piece"

class Board
  protected
  attr_accessor :piece_positions
  public
  attr_reader :piece_positions
  def setup
    @piece_positions = Hash.new
    (1..12).each do |num|
      @piece_positions[num] = Piece.new(:black)
    end
    (21..32).each do |num|
      @piece_positions[num] = Piece.new(:white)
    end
    self
  end

  def perform_moves(color, move_sequence)
    raise InvalidMoveError if !valid_move_seq?(color, move_sequence)
    perform_moves!(color, move_sequence)
  end

  def game_over?
    false
    #TODO game over when a player is out of pieces or out of moves
  end

protected
    def perform_moves!(color, move_sequence)

      move_sequence.each_index do |index|
        break if index > (move_sequence.length-2)
        start_pos = move_sequence[index]
        end_pos = move_sequence[index+1]
        delta = (end_pos-start_pos).abs
        if  delta == 3 || delta == 4 || delta == 5
          raise InvalidMoveError, "Piece can only have multiple moves of jumps." if move_sequence.length > 2
            perform_slide(color, start_pos, end_pos)
        elsif delta == 9 || delta == 7
          perform_jump(color, start_pos, end_pos)
        else
          raise InvalidMoveError, "Cannot move more than one diagonal sliding, or two diagonals jumping."
        end
      end
    end

    def perform_slide(color, start_pos, end_pos)
      piece = piece_at(start_pos)
      raise InvalidMoveError, "There is no piece at start position." if piece.nil?
      raise InvalidMoveError, "Cannot move pieces of opponent's color." if piece.color != color
      raise InvalidMoveError, "Piece cannot move to the designated position." if !piece.slide_moves(start_pos).include?(end_pos)
      raise InvalidMoveError, "Piece Cannot move to an occupied square." if !piece_at(end_pos).nil?

      @piece_positions[end_pos] = piece
      @piece_positions.delete(start_pos)
    end

    def perform_jump(color, start_pos, end_pos)
      piece = piece_at(start_pos)
      raise InvalidMoveError, "There is no piece at start position." if piece.nil?
      raise InvalidMoveError, "Cannot move pieces of opponent's color." if piece.color != color
      raise InvalidMoveError, "Piece cannot move to the designated position." if !piece.jump_moves(start_pos).include?(end_pos)
      raise InvalidMoveError, "Piece Cannot move to an occupied square." if !piece_at(end_pos).nil?

      jumped_pos = ((start_pos - end_pos).abs / 2.0).ceil + [start_pos, end_pos].min
      raise InvalidMoveError, "There is no piece to jump." if piece_at(jumped_pos).nil?
      raise InvalidMoveError, "Ally pieces cannot be jumped." if piece_at(jumped_pos).color == color

      @piece_positions[end_pos] = piece
      @piece_positions.delete(start_pos)
      @piece_positions.delete(jumped_pos)
    end

    def dup
      copy = Board.new
      copy.piece_positions = {}
      @piece_positions.each do |pos, piece|
        copy.piece_positions[pos] = piece.dup
      end
      copy
    end

    def valid_move_seq?(color, move_sequence)
      begin
        board_copy = self.dup
        board_copy.perform_moves!(color, move_sequence)
      rescue StandardError => e
        puts e.message
        return false
      else
        return true
      end
    end

    def piece_at(pos)
      if pos < 1 || pos > 32
        raise ArgumentError, "Board positions range 1-32. #{pos} was given."
      end
      @piece_positions[pos]
    end

end