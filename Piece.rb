class Piece
  def initialize(color)
    @promoted = false
    @color = color #red/white can move up, black can move down (unpromoted)
  end

  def slide_moves(board, piece_pos)
  end

  def jump_moves(board, piece_pos)
  end
end