class Piece
  def initialize(color)
    @promoted = false
    @color = color #red/white can move up, black can move down (unpromoted)
  end

  def slide_moves(board)
  end

  def jump_moves(board)
  end
end