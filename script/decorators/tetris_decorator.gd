extends "../decorator.gd"

var rule = 'triangle'

var shapes
var is_hollow
var margin_size
var border_size

func __shrink_corner(p0, p1, p2, depth):
	var e1 = (p0 - p1).normalized()
	var e2 = (p2 - p1).normalized()
	var cross = abs(e1.x * e2.y - e2.x * e1.y)
	if (cross < 1e-6):
		return p1 + Vector2(e2.y, -e2.x) * depth
	else:
		return p1 + (e1 + e2) * depth / cross

func __shrink_shape(shape, depth, scale):
	var result = []
	for i in range(len(shape)):
		var p0 = shape[i - 1] if i >= 1 else shape[len(shape) - 1]
		var p1 = shape[i]
		var p2 = shape[i + 1] if i + 1 < len(shape) else shape[0]
		result.append(__shrink_corner(p0, p1, p2, depth) * scale)
	return result

func draw_foreground(canvas: Visualizer.PuzzleCanvas, owner, owner_type: int, puzzle: Graph.Puzzle):
	var scale = 0.2 * (1 - puzzle.line_width)
	if (is_hollow):
		for shape in shapes:
			var hollow_shape = __shrink_shape(shape, margin_size, scale)
			if(!hollow_shape.empty()):
				hollow_shape.append(hollow_shape[0])
			var inner_shape = __shrink_shape(shape, border_size, scale)
			if (!inner_shape.empty()):
				inner_shape.append(inner_shape[0])
			inner_shape.invert()
			canvas.add_polygon(hollow_shape + inner_shape, color)
	else:
		for shape in shapes:
			canvas.add_polygon(__shrink_shape(shape, margin_size, scale), color)
	
