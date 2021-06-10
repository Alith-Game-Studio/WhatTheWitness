extends "../decorator.gd"

var rule = 'ghost'
var pattern: int

func draw_shape(canvas, puzzle, color):
	var multiplier = 1 if pattern == 0 else -1
	var radius = 0.425 * puzzle.line_width
	var tail_height = 0.5 * radius
	var points_arc = []
	var nb_points = 16
	for i in range(nb_points + 1):
		var angle_point = i * PI / nb_points
		points_arc.push_back(Vector2(cos(angle_point), sin(angle_point)) * radius * multiplier)
	for j in range(7):
		var x = (j / 3.0 - 1) * radius
		var y = -radius + j % 2 * tail_height
		points_arc.push_back(Vector2(x, y) * multiplier)
	canvas.add_polygon(points_arc, color)
	
func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	draw_shape(canvas, puzzle, color)
	
func draw_above_solution(canvas, owner, owner_type, puzzle, solution):
	draw_shape(canvas, puzzle, color) 
