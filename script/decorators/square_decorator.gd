extends "../decorator.gd"

var rule = 'square'

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	var circleRadius = 0.191 * (1 - puzzle.line_width)
	var distance = 0.067 * (1 - puzzle.line_width)
	var nb_points = 32
	var points_arc = []
	var angle_point
	for i in range(nb_points + 1):
		angle_point = 2 * (i + 0.5) * PI / nb_points
		var x = cos(angle_point) * circleRadius
		var y = sin(angle_point) * circleRadius
		points_arc.push_back(Vector2(x + sign(x) * distance, y + sign(y) * distance))
	canvas.add_polygon(points_arc, color)
