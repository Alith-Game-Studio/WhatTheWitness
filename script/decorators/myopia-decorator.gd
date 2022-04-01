extends "../decorator.gd"

var rule = 'myopia'

var directions = [] # each array element is [direction_vertex_id, direction_vector, is_nearest]

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	var arrow_length = 0.25 * (1 - puzzle.line_width)
	var arrow_head_width = 0.05 * (1 - puzzle.line_width)
	var arrow_head_length = 0.09 * (1 - puzzle.line_width)
	var arrow_width = 0.02 * (1 - puzzle.line_width)
	for direction in directions:
		if (direction[2] == true):
			var length_vec = direction[1]
			var width_vec = Vector2(-length_vec.y, length_vec.x)
			canvas.add_polygon([
					-arrow_width * width_vec,
					-arrow_width * width_vec + arrow_length * length_vec,
					(-arrow_width - arrow_head_width) * width_vec + arrow_length * length_vec,
					(arrow_length + arrow_head_length) * length_vec,
					(arrow_width + arrow_head_width) * width_vec + arrow_length * length_vec,
					arrow_width * width_vec + arrow_length * length_vec,
					arrow_width * width_vec,
				], color)
