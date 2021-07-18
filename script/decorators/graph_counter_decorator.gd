extends "../decorator.gd"

var rule = 'graph-counter'

var matrix: Array
var step_x: float
var step_y: float
var size: float
const DIR_X = [-1, 0, 1, 0]
const DIR_Y = [0, -1, 0, 1]
const MASK_LEFT = 0
const MASK_UP = 1
const MASK_RIGHT = 2
const MASK_DOWN = 3
const MASK_BROKEN = 4
const MASK_ROTATIONAL = 5
var rotational: bool

func get_rotational_symbol(old_symbol: int):
	if (old_symbol == 0):
		return old_symbol
	var min_symbol = old_symbol
	for i in range(4):
		min_symbol = min(min_symbol, (((old_symbol & 0xf) << i) % 0xf) | old_symbol & ~0xf)
	return min_symbol | 1 << MASK_ROTATIONAL

func draw_symbol(canvas: Visualizer.PuzzleCanvas, puzzle: Graph.Puzzle, pos: Vector2, symbol: int):
	if (symbol == 0):
		return
	var line_length = (1 - puzzle.line_width) * 0.4 * size
	var width = puzzle.line_width * 0.6 * size
	var nb_points = 8
	if (symbol & (1 << MASK_BROKEN)):
		for dir in range(4):
			if (symbol & (1 << dir)):
				canvas.add_line(line_length * Vector2(DIR_X[dir], DIR_Y[dir]) * 0.3 + pos, line_length * Vector2(DIR_X[dir], DIR_Y[dir]) + pos, width, color)
	else:
		var points = []
		for dir in range(4):
			var prev_dir = 3 if dir == 0 else dir - 1
			var vec = Vector2(DIR_X[dir], DIR_Y[dir])
			var prev_vec = Vector2(DIR_X[prev_dir], DIR_Y[prev_dir])
			if (symbol & (1 << dir)):
				points.append(line_length * vec + width / 2 * prev_vec + pos)
				points.append(line_length * vec - width / 2 * prev_vec + pos)
				points.append(width / 2 * (vec - prev_vec) + pos)
			else:
				if (not (symbol & (1 << prev_dir))):
					for i in range(nb_points):
						var angle = (i + 1) * PI / (nb_points * 2) + (dir + 1) * PI / 2
						points.append(Vector2(cos(angle), sin(angle)) * width / 2 + pos)
				else:
					points.append(width / 2 * vec + pos)
		canvas.add_polygon(points, color)
	
func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	for i in range(len(matrix)):
		var pos_y = (i - (len(matrix) - 1) / 2.0) * step_y
		for j in range(len(matrix[i])):
			var pos_x = (j - (len(matrix[i]) - 1) / 2.0) * step_x
			draw_symbol(canvas, puzzle, Vector2(pos_x, pos_y), matrix[i][j])
