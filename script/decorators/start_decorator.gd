extends "../decorator.gd"

func draw_foreground(canvas, owner, owner_type, puzzle):
	if (owner_type == 0):
		canvas.add_circle(owner.pos, 0.2, puzzle.line_color)


