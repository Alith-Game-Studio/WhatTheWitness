extends "../decorator.gd"

var rule = 'cosmic-house'
var satisfied = false
const HOUSE_POINTS = [
	Vector2(0, -1),
	Vector2(1, 0),
	Vector2(0.2, 0),
	Vector2(0.2, 0.3),
	Vector2(0.5, 0.3),
	Vector2(0.5, 0),
	Vector2(0.8, 0),
	Vector2(0.8, 1),
	Vector2(-0.8, 1),
	Vector2(-0.8, 0),
	Vector2(-0.5, 0),
	Vector2(-0.5, 0.3),
	Vector2(-0.2, 0.3),
	Vector2(-0.2, 0),
	Vector2(-1, 0),
]
const OCCUPIED_HOUSE_POINTS = [
	Vector2(0, -1),
	Vector2(1, 0),
	Vector2(0.8, 0),
	Vector2(0.8, 1),
	Vector2(-0.8, 1),
	Vector2(-0.8, 0),
	Vector2(-1, 0),
]
func draw_house(canvas, puzzle, pos, color, occupied):
	var length = 0.35 * (1 - puzzle.line_width)
	var points = []
	var original_points = OCCUPIED_HOUSE_POINTS if occupied else HOUSE_POINTS
	for point in original_points:
		points.append(point * length + pos)
	canvas.add_polygon(points, color)

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	draw_house(canvas, puzzle, Vector2.ZERO, color, false)
		
