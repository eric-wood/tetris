require 'curses'
require 'timeout'

include Curses

PIECE1 = <<PIECE
111100000000
111100000000
111111111111
111111111111
PIECE

PIECE2 = <<PIECE
000000001111
000000001111
111111111111
111111111111
PIECE

PIECE3 = <<PIECE
11111111
11111111
11111111
11111111
PIECE

PIECE4 = <<PIECE
1111
1111
1111
1111
1111
1111
1111
1111
PIECE

PIECE5 = <<PIECE
000011110000
000011110000
111111111111
111111111111
PIECE

def write(x, y, text)
  Curses.setpos(y, x)
  Curses.addstr(text)
end

def draw_piece(x, y, piece, color=@color)
  Curses.attron(color_pair(color))
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
    @bottom_pieces << [@posX, @posY, @piece, @color]
    @posX  = @width / 2
    @posY  = 0
    @piece = @pieces.sample
    @color = @colors.sample
  end
  
  @posX += dx
  @posY += dy
end

def init_colors
  Curses.init_pair(COLOR_RED, COLOR_RED, COLOR_RED)
  Curses.init_pair(COLOR_CYAN, COLOR_CYAN, COLOR_CYAN)
  Curses.init_pair(COLOR_GREEN, COLOR_GREEN, COLOR_GREEN)
  @colors = [COLOR_RED,COLOR_CYAN,COLOR_GREEN]
end

def init_screen
  Curses.noecho
  Curses.curs_set(0)
  Curses.init_screen
  Curses.start_color
  init_colors
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
  @pieces = [PIECE1, PIECE2, PIECE3, PIECE4, PIECE5]
  @piece = @pieces.sample
  @bottom_pieces = []
  @color = @colors.sample

  draw_piece(@posX, @posY, @piece)
  
  loop do
    begin
      Timeout::timeout(1) do
        case Curses.getch
          when Curses::Key::UP    then move_piece(0,-4)
          when Curses::Key::DOWN  then move_piece(0,4)
          when Curses::Key::LEFT  then move_piece(-4,0)
          when Curses::Key::RIGHT then move_piece(4,0)
        end
      end
    rescue Timeout::Error
      move_piece(0,4)
    end

    Curses.clear
    draw_piece(@posX, @posY, @piece)
    @bottom_pieces.each { |p| draw_piece(*p) }
    Curses.refresh
  end
end
