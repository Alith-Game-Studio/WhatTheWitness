extends "../decorator.gd"

var rule = 'graph-counter'

var type: int
const DIR_X = [-1, 0, 1, 0]
const DIR_Y = [0, -1, 0, 1]
const MASK_LEFT = 0
const MASK_UP = 1
const MASK_RIGHT = 2
const MASK_DOWN = 3
const MASK_BROKEN = 4
var count = 1

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	var line_length = (1 - puzzle.line_width) * 0.4
	var width = puzzle.line_width * 0.6
	var nb_points = 8
	if (type & (1 << MASK_BROKEN)):
		for dir in range(4):
			if (type & (1 << dir)):
				canvas.add_line(line_length * Vector2(DIR_X[dir], DIR_Y[dir]) * 0.3, line_length * Vector2(DIR_X[dir], DIR_Y[dir]), width, color)
	else:
		var points = []
		for dir in range(4):
			var prev_dir = 3 if dir == 0 else dir - 1
			var vec = Vector2(DIR_X[dir], DIR_Y[dir])
			var prev_vec = Vector2(DIR_X[prev_dir], DIR_Y[prev_dir])
			if (type & (1 << dir)):
				points.append(line_length * vec + width / 2 * prev_vec)
				points.append(line_length * vec - width / 2 * prev_vec)
				points.append(width / 2 * (vec - prev_vec))
			else:
				if (not (type & (1 << prev_dir))):
					for i in range(nb_points):
						var angle = (i + 1) * PI / (nb_points * 2) + (dir + 1) * PI / 2
						points.append(Vector2(cos(angle), sin(angle)) * width / 2)
				else:
					points.append(width / 2 * vec)
		canvas.add_polygon(points, color)
	
