extends "../decorator.gd"

var rule = 'broken'

var direction : Vector2

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	canvas.add_line(
		-direction * puzzle.line_width / 2, 
		direction * puzzle.line_width / 2, 
		puzzle.line_width, 
		puzzle.line_color
	)
