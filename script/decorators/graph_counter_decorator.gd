extends "../decorator.gd"

var rule = 'graph-counter'

var matrix: Array
var step_x: float
var step_y: float
var size: float
const N_DIRS = 24
const MASK_LEFT = 0
const MASK_UP = 6
const MASK_RIGHT = 12
const MASK_DOWN = 18
const MASK_BROKEN = 24
const MASK_ROTATIONAL = 25
var rotational: bool

func get_rotational_symbol(old_symbol: int):
	if (old_symbol == 0):
		return old_symbol
	var min_symbol = old_symbol
	var mask = (1 << N_DIRS) - 1
	for i in range(N_DIRS):
		min_symbol = min(min_symbol, (((old_symbol & mask) << i) % mask) | old_symbol & ~mask)
	return min_symbol | 1 << MASK_ROTATIONAL

func dir_to_vec(dir):
	return -Vector2(cos(dir * 2 * PI / N_DIRS), sin(dir * 2 * PI / N_DIRS))

func draw_symbol(canvas: Visualizer.PuzzleCanvas, puzzle: Graph.Puzzle, pos: Vector2, symbol: int):
	if (symbol == 0):
		return
	var line_length = (1 - puzzle.line_width) * 0.35 * size
	var width = puzzle.line_width * 0.7 * size
	var nb_points = 8
	if (symbol & (1 << MASK_BROKEN)):
		for dir in range(N_DIRS):
			if (symbol & (1 << dir)):
				canvas.add_line(line_length * dir_to_vec(dir) * 0.3 + pos, line_length * dir_to_vec(dir) + pos, width, color)
	else:
		for dir in range(N_DIRS):
			if (symbol & (1 << dir)):
				canvas.add_line(pos, line_length * dir_to_vec(dir) + pos, width, color)
		canvas.add_circle(pos, width / 2, color)
func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	for i in range(len(matrix)):
		var pos_y = (i - (len(matrix) - 1) / 2.0) * step_y
		for j in range(len(matrix[i])):
			var pos_x = (j - (len(matrix[i]) - 1) / 2.0) * step_x
			draw_symbol(canvas, puzzle, Vector2(pos_x, pos_y), matrix[i][j])
