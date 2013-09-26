class Piece
  attr_reader :color
  attr_accessor :promoted

  def initialize(color)
    @promoted = false
    @color = color #red/white can move up, black can move down (unpromoted)
  end

  def slide_moves(pos)
    moves = []
    if row_num(pos).odd?
      moves = [pos-4, pos-3, pos+4, pos+5]

      if pos < 5#top of board
        moves.delete(pos-4)
        moves.delete(pos-3)
      end

      #Odd rows should not appear at left end of board, so just remove right ones
      if col_end(pos) == 1#right end
        moves.delete(pos-3)
        moves.delete(pos+5)
      end
    else#even row
      moves = [pos-5, pos-4, pos+3, pos+4]
      if pos > 28 #bottom of board
        moves.delete(pos+4)
        moves.delete(pos+5)
      end

      #Even rows should not appear at right end of board, so just remove left ones
      if col_end(pos) == -1#left end
        moves.delete(pos+3)
        moves.delete(pos-5)
      end
    end

    #remove back dir slides if not promoted
    if !promoted
      if color == :white#white moves up
        moves.delete_if {|num| num > pos}
      else#black moves down
        moves.delete_if {|num| num < pos}
      end
    end
  end

  def jump_moves(pos)
    moves = [pos-9, pos-7, pos+7, pos+9]

    if pos < 9#top two rows of board
      moves.delete(pos-4)
      moves.delete(pos-3)
    end
    if pos > 24 #bottom two rows of board
      moves.delete(pos+4)
      moves.delete(pos+5)
    end

    #Odd rows should not appear at left end of board, so just remove right ones

    if col_end(pos) < 0#left end
      moves.delete(pos+7)
      moves.delete(pos-9)
    elsif col_end(pos) > 0#right end
      moves.delete(pos-7)
      moves.delete(pos+9)
    end

    #remove back dir slides if not promoted
    if !promoted
      if color == :white#white moves up
        moves.delete_if {|num| num > pos}
      else#black moves down
        moves.delete_if {|num| num < pos}
      end
    end
  end

  def check_promote(pos)
    if !@promoted
      @promoted = true if color == :white && pos > 0 && pos < 5
      @promoted = true if color == :black && pos < 32 && pos > 28
    end
  end

  def row_num(pos)
    (pos/4.0).ceil
  end

  def col_end(pos)
    return -1 if [5,13,21,29].include?(pos)
    return -2 if [1,9,17,25].include?(pos)
    return 1 if [4,12,20,28].include?(pos)
    return 2 if [8,16,24,32].include?(pos)
    return 0
  end
end