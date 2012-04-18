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

width  = Curses.cols
height = Curses.lines
posX = 0
posY = 0
@piece = PIECE1

def write(x, y, text)
  Curses.setpos(y, x)
  Curses.addstr(text)
end

def draw_piece(x, y, piece)
  blocks = piece.split.map { |i| i.split(//) }
  blocks.each_with_index do |row,i|
    row.each_with_index do |c,j|
      write(y-j, x+i, c)
    end
  end
end

def move_piece(dx, dy)
  p dx
  p dy
  posX = 0 if posX + dx < 0
  posY = 0 if posY + dy < 0
  return nil if dx == 0 || dy == 0

  Curses.clear
  draw_piece(posX, posY, @piece)
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
  draw_piece(posX, posY, @piece)
  
  loop do
    Curses.refresh
    
    case Curses.getch
      when Curses::Key::UP    then move_piece(0, -1)
      when Curses::Key::DOWN  then move_piece(0, 1)
      when Curses::Key::LEFT  then move_piece(-1, 0)
      when Curses::Key::RIGHT then move_piece(1, 0)
    end
  end
end
