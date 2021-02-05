extends "../decorator.gd"

var rule = 'broken'

func draw_foreground(canvas, owner, owner_type, puzzle):
	var width = 0.4330127 * puzzle.line_width
	var x2 = 0.3247595 * puzzle.line_width
	var radius = 0.375 * puzzle.line_width
	if (owner_type == 0):
		canvas.add_line(
			owner.pos + Vector2(0, -radius), 
			owner.pos + Vector2(0, radius), 
			width, 
			Color.black
		)
		canvas.add_line(
			owner.pos + Vector2(-x2, radius / 2), 
			owner.pos + Vector2(x2, -radius / 2), 
			width, 
			Color.black
		)
		canvas.add_line(
			owner.pos + Vector2(x2, radius / 2), 
			owner.pos + Vector2(-x2, -radius / 2), 
			width, 
			Color.black
		)
