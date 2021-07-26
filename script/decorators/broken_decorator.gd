extends "../decorator.gd"

var rule = 'broken'

var direction : Vector2

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	canvas.add_line(
		-direction, 
		direction, 
		puzzle.line_width * 1.05, 
		puzzle.background_color
	)
