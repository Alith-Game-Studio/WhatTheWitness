extends "../decorator.gd"

var rule = 'all-error'
const END_DIRECTIONS = [Vector2(0.0, -1.0), Vector2(-0.8660254, 0.5), Vector2(0.8660254, 0.5)]

const curve_points_template = [
	Vector2(-0.046, -0.176),
	Vector2(0.046, -0.176),
	Vector2(0.046, -0.0264),
	Vector2(0.18456, 0.0536),
	Vector2(0.13856, 0.13312),
	Vector2(0.0, 0.05312),
	Vector2(-0.13856, 0.13312),
	Vector2(-0.18456, 0.0536),
	Vector2(-0.046, -0.0264),
	
]

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	canvas.add_polygon(curve_points_template, color)

func draw_above_solution(canvas, owner, owner_type, puzzle, solution):
	canvas.add_polygon(curve_points_template, color)
 
