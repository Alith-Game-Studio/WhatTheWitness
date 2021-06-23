extends "../decorator.gd"

var rule = 'emitter'

func draw_shape(canvas, puzzle, color):
	var circleRadius = 0.1
	var innerRadius = 0.05
	var nb_points = 32
	var points_arc = []
	var angle_point
	for i in range(7):
		angle_point = 2 * i * PI / nb_points
		points_arc.push_back(Vector2(cos(angle_point), sin(angle_point)) * circleRadius)
	points_arc.push_back(Vector2(0.035, 0.2))
	points_arc.push_back(Vector2(-0.035, 0.2))
	for i in range(10, nb_points + 1):
		angle_point = 2 * i * PI / nb_points
		points_arc.push_back(Vector2(cos(angle_point), sin(angle_point)) * circleRadius)
	for i in range(nb_points + 1):
		angle_point = -2 * i * PI / nb_points
		points_arc.push_back(Vector2(cos(angle_point), sin(angle_point)) * innerRadius)
	canvas.add_polygon(points_arc, color)
	
func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	draw_shape(canvas, puzzle, color)
	
