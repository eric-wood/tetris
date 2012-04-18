require 'curses'

width  = Curses.cols
height = Curses.lines
posX = 0
posY = 0

PIECE = <<PIECE
OO
OO
OOOOOO
OOOOOO
PIECE

def onsig(sig)
  close_screen
  exit(sig)
end

for i in 1 .. 15  # SIGHUP .. SIGTERM
  if trap(i, "SIG_IGN") != 0 then  # 0 for SIG_IGN
    trap(i) {|sig| onsig(sig) }
  end
end

def write(line, col, text)
  Curses.setpos(line, col)
  Curses.addstr(text)
end

def init_screen
  Curses.noecho
  Curses.init_screen
  Curses.stdscr.keypad(true)
  begin
    yield
  ensure
    Curses.close_screen
  end
end

init_screen do
  loop do
    Curses.refresh
    write(posX,posY,PIECE)
    
    case Curses.getch
      when Curses::Key::UP then    posX -= 1
      when Curses::Key::DOWN then  posX += 1
      when Curses::Key::LEFT then  posY -= 1
      when Curses::Key::RIGHT then posY += 1
    end
  end
end
