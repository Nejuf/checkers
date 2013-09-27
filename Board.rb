require_relative 'errors'
require_relative "Piece"
require 'colorize'

class Board
  protected
  attr_accessor :piece_positions
  public
  attr_reader :piece_positions
  def initialize
    @show_help_board = true
    setup
  end
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
    raise InvalidMoveError.new "Invalid move." if !valid_move_seq?(color, move_sequence)
    perform_moves!(color, move_sequence)
  end

  def game_over?
    false
    #TODO game over when a player is out of pieces or out of moves
  end

  def render
    puts
    8.times do |row|
      row_string = ""
      help_string = "     "
      8.times do |col|
        piece = piece_at(coord_to_pos(row,col))
        col_string = ""
        if piece.nil?
          col_string = " "
        elsif piece.color == :white
          col_string = "W"
          col_string = "WK" if piece.promoted
        else#black
          col_string = "B"
          col_string = "BK" if piece.promoted
        end
        row_string << col_string.center(3).on_red if col.even? != row.even?
        row_string << col_string.center(3).on_white if col.even? == row.even?

        if @show_help_board
          help_char = " "
          help_pos = coord_to_pos(row,col)
          help_char =  help_pos.to_s unless help_pos.nil?
          help_string << help_char.center(3).on_red if col.even? != row.even?
          help_string << help_char.center(3).on_white if col.even? == row.even?
        end
      end
      row_string << help_string if @show_help_board
      puts row_string
      puts
    end
    puts
  end


    def perform_moves!(color, move_sequence)
      positions_jumped = []
      (0...(move_sequence.length-1)).each do |index|
        break if index > (move_sequence.length-2)
        start_pos = move_sequence[index]
        end_pos = move_sequence[index+1]
        delta = (end_pos-start_pos).abs
        if  delta == 3 || delta == 4 || delta == 5
          raise InvalidMoveError.new "Piece can only have multiple moves of jumps." if move_sequence.length > 2
          perform_slide(color, start_pos, end_pos)
        elsif delta == 9 || delta == 7
          positions_jumped << perform_jump(color, start_pos, end_pos, positions_jumped)
        else
          raise InvalidMoveError.new "Cannot move more than one diagonal sliding, or two diagonals jumping."
        end
      end

      #Enforce must make available jump rule
      if !positions_jumped.empty?#no need to enforce when no pieces have been jumped
        last_pos = move_sequence.last
        potential_jumps = piece_at(last_pos).jump_moves(last_pos)
        if !potential_jumps.empty?
          valid_jump = nil
          potential_jumps.each do |jump_dest_pos|
            begin
              #p "perform_jump #{color} #{last_pos} #{jump_dest_pos} #{positions_jumped}"
              perform_jump(color, last_pos, jump_dest_pos, positions_jumped)
            rescue => e
            else
              valid_jump = jump_dest_pos
            end
          end
          if !valid_jump.nil?
            raise InvalidMoveError.new "If there is a valid jump following another jump, it must be made.\n--Valid jump to #{valid_jump} was found at end of given jump sequence."
          end
        end
      end
    end

    def perform_slide(color, start_pos, end_pos)
      piece = piece_at(start_pos)
      raise InvalidMoveError.new "There is no piece at start position. #{start_pos}" if piece.nil?
      raise InvalidMoveError.new "Cannot move pieces of opponent's color. #{start_pos}" if piece.color != color
      raise InvalidMoveError.new "Piece cannot move to the designated position. #{end_pos}" if !piece.slide_moves(start_pos).include?(end_pos)
      raise InvalidMoveError.new "Piece Cannot move to an occupied square. #{end_pos}" if !piece_at(end_pos).nil?

      piece.check_promote(end_pos)
      @piece_positions[end_pos] = piece
      @piece_positions.delete(start_pos)
    end

    def perform_jump(color, start_pos, end_pos, positions_jumped)
      piece = piece_at(start_pos)
      raise InvalidMoveError.new "There is no piece at start position. #{start_pos}" if piece.nil?
      raise InvalidMoveError.new "Cannot move pieces of opponent's color. #{start_pos}" if piece.color != color
      raise InvalidMoveError.new "Piece cannot move to the designated position. #{end_pos}" if !piece.jump_moves(start_pos).include?(end_pos)
      raise InvalidMoveError.new "Piece cannot move to an occupied square. #{end_pos}" if !piece_at(end_pos).nil?

      raise InvalidMoveError.new "Piece cannot jump to the position of a jumped piece in the same turn." if positions_jumped.include?(end_pos)
      smallest_pos = [start_pos, end_pos].min
      delta = (start_pos - end_pos).abs
      offset = 0
      offset = 5 if delta == 9 && Piece.row_num(smallest_pos).odd?
      offset = 4 if delta == 9 && Piece.row_num(smallest_pos).even?
      offset = 4 if delta == 7 && Piece.row_num(smallest_pos).odd?
      offset = 3 if delta == 7 && Piece.row_num(smallest_pos).even?
      raise "something is wrong with the delta or position" if offset == 0

      jumped_pos = offset + smallest_pos
      raise InvalidMoveError.new "Piece cannot jump over a piece jumped in the same turn." if positions_jumped.include?(jumped_pos)
      raise InvalidMoveError.new "There is no piece to jump. #{jumped_pos}" if piece_at(jumped_pos).nil?
      raise InvalidMoveError.new "Ally pieces cannot be jumped. #{jumped_pos}" if piece_at(jumped_pos).color == color

      piece.check_promote(end_pos)
      @piece_positions[end_pos] = piece
      @piece_positions.delete(start_pos)
      @piece_positions.delete(jumped_pos)

      jumped_pos
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
      rescue InvalidMoveError => e
        raise InvalidMoveError.new e.message
        return false
      else
        return true
      end
    end

    #assumes top left as 0,0 and row as first element and black at top
    def coord_to_pos(row,col)
      return nil if row.even? && col.even? || row.odd? && col.odd? #these are always empty squares in checkers!
      return row*4+(col/2).floor+1
    end

    def piece_at(pos)
      if pos.nil?
        return nil
      end
      if pos < 1 || pos > 32
        raise ArgumentError.new "Board positions range 1-32. #{pos} was given."
      end

      @piece_positions[pos]
    end

end