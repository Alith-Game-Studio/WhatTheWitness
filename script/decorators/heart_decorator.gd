extends "../decorator.gd"

var rule = 'heart'

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	var radius = 0.1 * (1 - puzzle.line_width)
	var nb_points = 32
	var points_arc = []
	for i in range(nb_points + 1):
		var t = 2 * i * PI / nb_points
		var sint = sin(t)
		var r = sint * sqrt(abs(cos(t))) / (sint + 1.4) - 2 * sint + 2
		points_arc.push_back(Vector2(cos(t), -sin(t)) * r * radius - Vector2(0, 1.5 * radius))

	canvas.add_polygon(points_arc, color)
	
