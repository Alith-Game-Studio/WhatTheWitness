extends "../decorator.gd"

var rule = 'drop'

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	var circleRadius = 0.18 * (1 - puzzle.line_width)
	var nb_points = 32
	var points_arc = []
	var angle_point
	for i in range(5, nb_points - 4):
		angle_point = 2 * i * PI / nb_points
		points_arc.push_back(Vector2(sin(angle_point), -cos(angle_point) + 0.5) * circleRadius)
	points_arc.push_back(Vector2(0, -1.5 * circleRadius))
	canvas.add_polygon(points_arc, color)
	

