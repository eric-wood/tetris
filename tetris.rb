require 'curses'

PIECE1 = <<PIECE
OO
OO
OOOOOO
OOOOOO
PIECE

PIECE2 = <<PIECE
    OO
    OO
OOOOOO
OOOOOO
PIECE

def write(x, y, text)
  Curses.setpos(y, x)
  Curses.addstr(text)
end

def draw_piece(x, y, piece)
  blocks = piece.split.map { |i| i.split(//) }
  blocks.each_with_index do |row,i|
    row.each_with_index do |c,j|
      write(x+j, y+i, c)
    end
  end
end

def move_piece(dx, dy)
  return nil if @posX + dx < 0
  return nil if @posY + dy < 0

  max_x = @piece.split.max_by { |i| i.size }.size
  return nil if (@posX + dx + max_x) >= @width
  max_y = @piece.split.size
  return nil if (@posY + dy + max_y) > @height
  @posX += dx
  @posY += dy
end

def init_screen
  Curses.noecho
  Curses.curs_set(0)
  Curses.init_screen
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
  @posX = 0
  @posY = 0
  @piece = PIECE1

  draw_piece(@posX, @posY, @piece)
  
  loop do
    case Curses.getch
      when Curses::Key::UP    then move_piece(0, -1)
      when Curses::Key::DOWN  then move_piece(0, 1)
      when Curses::Key::LEFT  then move_piece(-1, 0)
      when Curses::Key::RIGHT then move_piece(1, 0)
    end

    Curses.clear
    write(@width-15, @height-1, "(#{@posX},#{@posY})")
    draw_piece(@posX, @posY, @piece)
    Curses.refresh
  end
end
