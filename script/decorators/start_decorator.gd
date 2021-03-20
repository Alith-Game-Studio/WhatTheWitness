extends "../decorator.gd"

var rule = 'start'

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	if (owner_type == 0):
		canvas.add_circle(Vector2.ZERO, puzzle.start_size, puzzle.line_color)


