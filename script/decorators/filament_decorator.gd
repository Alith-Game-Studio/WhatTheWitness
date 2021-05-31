extends "../decorator.gd"

var rule = 'filament-pillar'
var circleRadius = 0.08

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	canvas.add_circle(Vector2.ZERO, circleRadius, color)
		
