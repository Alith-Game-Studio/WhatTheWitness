extends "../decorator.gd"

var rule = 'square'

func draw_foreground(canvas, owner, owner_type, puzzle, solution):
	if (owner_type == Graph.FACET_ELEMENT):
		var circleRadius = 0.191 * (1 - puzzle.line_width)
		var distance = 0.067 * (1 - puzzle.line_width)
		canvas.add_circle(Vector2(distance, distance) + owner.center, circleRadius, color)
		canvas.add_circle(Vector2(-distance, distance) + owner.center, circleRadius, color)
		canvas.add_circle(Vector2(distance, -distance) + owner.center, circleRadius, color)
		canvas.add_circle(Vector2(-distance, -distance) + owner.center, circleRadius, color)
		canvas.add_line(Vector2(-distance - circleRadius, 0) + owner.center, Vector2(distance + circleRadius, 0) + owner.center, 2 * distance, color)
		canvas.add_line(Vector2(0, -distance - circleRadius) + owner.center, Vector2(0, distance + circleRadius) + owner.center, 2 * distance, color)
