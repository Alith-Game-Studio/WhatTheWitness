extends "../decorator.gd"

var rule = 'tetris'

var shapes
var is_hollow
var margin_size
var border_size
var covering: Array
const ROTATION_ANGLES = [0, PI / 3, 2 * PI / 3, PI / 2, PI, 3 * PI / 2]

func angle_equal_zero(angle, eps=1e-3):
	var d = round(angle / (2 * PI))
	return abs(angle - (2 * d * PI)) < eps

func calculate_covering(puzzle):
	var rotatable = true 
	# test if the tetris is skewed
	# in the level editor we usually use 15 degrees or -15 degrees of angle
	# to represent that a tetris is skewed
	for std_angle in ROTATION_ANGLES:
		if (angle_equal_zero(angle - std_angle)):
			rotatable = false
			break
	var test_angles = ROTATION_ANGLES if rotatable else [angle]
	var shape_centers = []
	for shape in shapes:
		var center = Vector2(0, 0)
		for pos in shape:
			center += pos
		shape_centers.append(center / len(shape))
	covering = []
	var covering_dict = {}
	for angle in test_angles:
		var transform = Transform2D().rotated(angle)
		for i in range(len(puzzle.facets)):
			var ok = true
			var facet_center = puzzle.facets[i].center
			# align the facet center with the shape center
			var relative_pos = facet_center - transform.xform(shape_centers[0])
			transform[2] += relative_pos
			# check if all centers aligned
			var alignment = []
			for k in range(len(shape_centers)):
				var shape_center = shape_centers[k]
				var edge_count = len(shapes[k])
				var transformed_center = transform.xform(shape_center)
				var found_alignment = false
				for j in range(len(puzzle.facets)):
					if (len(puzzle.facets[j].vertices) == edge_count and
						puzzle.facets[j].center.distance_squared_to(transformed_center) < 1e-4):
						alignment.append(j)
						found_alignment = true
						break
				if (!found_alignment):
					ok = false
					break
			# todo: check if all vertices are aligned
			if (ok):
				alignment.sort()
				if (!(alignment in covering_dict)):
					covering_dict[alignment] = true
					covering.append(alignment)
	# print('Covering of %d:' % len(shapes), covering)
			
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
	
