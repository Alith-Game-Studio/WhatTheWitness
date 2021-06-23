extends "../decorator.gd"

var rule = 'laser-emitter'

func draw_shape(canvas, puzzle, color):
	var innerRadius = 0.05
	var nb_points = 32
	var points_arc = []
	var angle_point
	for i in range(nb_points + 1):
		angle_point = 2 * i * PI / nb_points
		points_arc.push_back(Vector2(cos(angle_point), sin(angle_point)) * innerRadius)
	canvas.add_polygon(points_arc, color)
	points_arc = [
		Vector2(-0.07, 0.04),
		Vector2(-0.09, 0.06),
		Vector2(0, 0.15),
		Vector2(0.09, 0.06),
		Vector2(0.07, 0.04),
		Vector2(0, 0.11),
	]
	canvas.add_polygon(points_arc, color)
	
func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	draw_shape(canvas, puzzle, color)
	
