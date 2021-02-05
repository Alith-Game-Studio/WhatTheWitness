extends "../decorator.gd"

var rule = 'broken'

var direction : Vector2

func draw_foreground(canvas, owner, owner_type, puzzle):
	if (owner_type == 0):
		canvas.add_line(
			owner.pos - direction * puzzle.line_width / 2, 
			owner.pos + direction * puzzle.line_width / 2, 
			puzzle.line_width, 
			puzzle.line_color
		)
