require 'curses'
include Curses

PIECE1 = <<PIECE
110000
110000
111111
111111
PIECE

PIECE2 = <<PIECE
000011
000011
111111
111111
PIECE

def write(x, y, text)
  Curses.setpos(y, x)
  Curses.addstr(text)
end

def draw_piece(x, y, piece)
  Curses.attron(color_pair(COLOR_RED))
  blocks = piece.split.map { |i| i.split(//) }
  blocks.each_with_index do |row,i|
    row.each_with_index do |c,j|
      write(x+j, y+i, c) if c == "1"
    end
  end
  Curses.attroff(color_pair(COLOR_RED))
end

def move_piece(dx, dy)
  return nil if @posX + dx < 0
  return nil if @posY + dy < 0

  max_x = @piece.split.max_by { |i| i.size }.size
  return nil if (@posX + dx + max_x) >= @width
  max_y = @piece.split.size

  # Piece has reached the bottom
  if (@posY + dy + max_y) > @height
    @bottom_pieces << [@posX, @posY, @piece]
    @posX  = @width / 2
    @posY  = 0
    @piece = @pieces.sample
  end
  
  @posX += dx
  @posY += dy
end

def init_screen
  Curses.noecho
  Curses.curs_set(0)
  Curses.init_screen
  Curses.start_color
  Curses.init_pair(COLOR_RED, COLOR_RED, COLOR_RED)
  Curses.stdscr.keypad(true)
  begin
    yield
  ensure
    Curses.close_screen
  end
end

init_screen do
  @width  = Curses.cols
  @height = Curses.lines
  @posX = @width / 2
  @posY = 0
  @pieces = [PIECE1, PIECE2]
  @piece = @pieces.sample
  @bottom_pieces = []

  draw_piece(@posX, @posY, @piece)
  
  loop do
    case Curses.getch
      when Curses::Key::UP    then move_piece(0, -1)
      when Curses::Key::DOWN  then move_piece(0, 1)
      when Curses::Key::LEFT  then move_piece(-1, 0)
      when Curses::Key::RIGHT then move_piece(1, 0)
    end

    Curses.clear
    draw_piece(@posX, @posY, @piece)
    @bottom_pieces.each { |p| draw_piece(*p) }
    Curses.refresh
  end
end
