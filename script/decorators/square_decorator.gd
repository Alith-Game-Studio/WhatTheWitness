extends "../decorator.gd"

var rule = 'square'

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	if (owner_type == Graph.FACET_ELEMENT):
		var circleRadius = 0.191 * (1 - puzzle.line_width)
		var distance = 0.067 * (1 - puzzle.line_width)
		canvas.add_circle(Vector2(distance, distance) , circleRadius, color)
		canvas.add_circle(Vector2(-distance, distance) , circleRadius, color)
		canvas.add_circle(Vector2(distance, -distance) , circleRadius, color)
		canvas.add_circle(Vector2(-distance, -distance) , circleRadius, color)
		canvas.add_line(Vector2(-distance - circleRadius, 0) , Vector2(distance + circleRadius, 0) , 2 * distance, color)
		canvas.add_line(Vector2(0, -distance - circleRadius) , Vector2(0, distance + circleRadius) , 2 * distance, color)
