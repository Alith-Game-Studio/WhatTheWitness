extends "../decorator.gd"

var rule = 'star'

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	var distance = [0.2743 * (1 - puzzle.line_width), 0.21 * (1 - puzzle.line_width)]
	var points_arc = []
	var angle_point
	for i in range(16):
		angle_point = 2 * i * PI / 16
		var x = cos(angle_point) * distance[i % 2]
		var y = sin(angle_point) * distance[i % 2]
		points_arc.push_back(Vector2(x, y))
	canvas.add_polygon(points_arc, color)
