extends "../decorator.gd"

var rule = 'arrow'

var count

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	if (owner_type == 2):
		var width = 0.3 * (1 - puzzle.line_width)
		var thickness = 0.08 * (1 - puzzle.line_width)
		var delta_height = thickness * 1.414213562
		var arrow_distance = 0.08 * (1 - puzzle.line_width)
		var bar_length = 0.4 * (1 - puzzle.line_width)
		var head_height = 0.3 * (1 - puzzle.line_width) - thickness / 2
		var points = []
		var current_height = bar_length
		points.append(Vector2(0, current_height + thickness * head_height / (2 * width)) )
		for i in range(count):
			points.append(Vector2(-width, current_height - head_height) )
			current_height -= delta_height
			points.append(Vector2(-width, current_height - head_height) )
			points.append(Vector2(-thickness / 2, current_height) )
			current_height -= arrow_distance
			points.append(Vector2(-thickness / 2, current_height) )
		points.append(Vector2(-thickness / 2, -bar_length) )
		points.append(Vector2(thickness / 2, -bar_length) )
		for i in range(count):
			points.append(Vector2(thickness / 2, current_height) )
			current_height += arrow_distance
			points.append(Vector2(thickness / 2, current_height) )
			points.append(Vector2(width, current_height - head_height) )
			current_height += delta_height
			points.append(Vector2(width, current_height - head_height) )
		canvas.add_polygon(points, color)
