extends "../decorator.gd"

var rule = 'ring'

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	var circleRadius = 0.35 * (1 - puzzle.line_width)
	var innerRadius = 0.25 * (1 - puzzle.line_width)
	var nb_points = 32
	var points_arc = []
	var angle_point
	for i in range(nb_points + 1):
		angle_point = 2 * i * PI / nb_points
		points_arc.push_back(Vector2(cos(angle_point), sin(angle_point)) * circleRadius)
	for i in range(nb_points + 1):
		angle_point = -2 * i * PI / nb_points
		points_arc.push_back(Vector2(cos(angle_point), sin(angle_point)) * innerRadius)
	canvas.add_polygon(points_arc, color)
	
