extends "../decorator.gd"

var rule = 'circle'

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	if (owner_type == Graph.FACET_ELEMENT):
		var circleRadius = 0.35 * (1 - puzzle.line_width)
		canvas.add_circle(Vector2.ZERO, circleRadius, color)
		

