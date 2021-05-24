extends "../decorator.gd"

var rule = 'eliminator'
const END_DIRECTIONS = [Vector2(0.0, -1.0), Vector2(-0.8660254, 0.5), Vector2(0.8660254, 0.5)]

const curve_points = [
	Vector2(-0.0575, -0.22),
	Vector2(0.0575, -0.22),
	Vector2(0.0575, -0.033),
	Vector2(0.2307, 0.067),
	Vector2(0.1732, 0.1664),
	Vector2(0.0, 0.0664),
	Vector2(-0.1732, 0.1664),
	Vector2(-0.2307, 0.067),
	Vector2(-0.0575, -0.033),
	
]

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	canvas.add_polygon(curve_points, color)

