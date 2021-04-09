extends "../decorator.gd"

var rule = 'wall'
const texture = preload("res://img/obstacle.png")

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	var circleRadius = 0.35
	canvas.add_texture(Vector2.ZERO, Vector2(circleRadius * 2, circleRadius * 2), texture)
