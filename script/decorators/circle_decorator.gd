extends "../decorator.gd"

var rule = 'circle'

func draw_foreground(canvas, owner, owner_type, puzzle, solution):
	if (owner_type == Graph.FACET_ELEMENT):
		var circleRadius = 0.35 * (1 - puzzle.line_width)
		canvas.add_circle(owner.center, circleRadius, color)
		

