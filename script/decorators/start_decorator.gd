extends "../decorator.gd"

var rule = 'start'

func draw_foreground(canvas, owner, owner_type, puzzle, solution):
	if (owner_type == 0):
		canvas.add_circle(owner.pos, puzzle.start_size, puzzle.line_color)


