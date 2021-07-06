extends "../decorator.gd"

var rule = 'circle-arrow'

var is_clockwise

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	var circleRadius = 0.32 * (1 - puzzle.line_width)
	var innerRadius = 0.25 * (1 - puzzle.line_width)
	var arrowSize = 0.1 * (1 - puzzle.line_width)
	var nb_points = 32
	var points_arc = []
	var angle_point
	var dir = 1 if is_clockwise else -1
	for i in range(nb_points - 5):
		angle_point = 2 * i * PI / nb_points
		points_arc.push_back(Vector2(dir * cos(angle_point), sin(angle_point)) * circleRadius)
	points_arc.push_back(Vector2(dir * cos(angle_point), sin(angle_point)) * (arrowSize + circleRadius))
	points_arc.push_back(Vector2(dir * cos(angle_point + PI / 6), sin(angle_point + PI / 6)) * (innerRadius + circleRadius) / 2)
	points_arc.push_back(Vector2(dir * cos(angle_point), sin(angle_point)) * (innerRadius - arrowSize))
	
	for i in range(nb_points - 6, -1, -1):
		angle_point = 2 * i * PI / nb_points
		points_arc.push_back(Vector2(dir * cos(angle_point), sin(angle_point)) * innerRadius)
	canvas.add_polygon(points_arc, color)
