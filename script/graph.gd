extends Node

var better_xml = preload("res://script/better_xml.gd").new()
var directory = Directory.new()

const VERTEX_ELEMENT = 0
const EDGE_ELEMENT = 1
const FACET_ELEMENT = 2
const GLOBAL_ELEMENT = 3

const SYMMETRY_ROTATIONAL = 0
const SYMMETRY_REFLECTIVE = 1

class Vertex:
	var pos: Vector2
	var decorator = load("res://script/decorators/no_decorator.gd").new()
	func _init(x, y):
		pos.x = x
		pos.y = y

class Edge:
	var start: Vertex
	var end: Vertex
	var end_is_crossroad: bool
	var start_index: int
	var end_index: int
	var decorator = load("res://script/decorators/no_decorator.gd").new()
	func _init(v1, v2):
		start = v1
		end = v2
		
	
class Facet:
	var edge_tuples: Array
	var vertices: Array
	var center: Vector2
	var decorator = load("res://script/decorators/no_decorator.gd").new()
	func _init(vs):
		vertices = vs
		center = Vector2.ZERO
		for v in vertices:
			center += v.pos
		center /= len(vertices)
	
class Puzzle:
	var vertices: Array
	var edges: Array
	var facets: Array
	var line_color: Color
	var background_color: Color
	var solution_colors: Array
	var line_width: float
	var start_size: float
	var n_ways: int
	var symmetry_type: int
	var symmetry_center: Vector2
	var symmetry_angle: float
	var decorators : Array
	var edge_detector_node = {}
	var edge_shared_facets = {}
	
	func get_vertex_at(position, eps=1e-3):
		for vertex in vertices:
			if ((vertex.pos - position).length() <= eps):
				return vertex
		return null
	
func push_vertex_vec(puzzle, pos):
	var result = len(puzzle.vertices)
	puzzle.vertices.push_back(Vertex.new(pos.x, pos.y))
	return result

func push_edge_idx(puzzle, idx1, idx2):
	var result = len(puzzle.edges)
	var edge = Edge.new(puzzle.vertices[idx1], puzzle.vertices[idx2])
	edge.start_index = idx1
	edge.end_index = idx2
	edge.end_is_crossroad = false
	puzzle.edges.push_back(edge)
	return edge
	
func __get_raw_element_center(puzzle, raw_element, element_type, id):
	if (element_type == EDGE_ELEMENT):
		var v1 = int(raw_element['Start'])
		var v2 = int(raw_element['End'])
		var p1 = puzzle.vertices[v1].pos
		var p2 = puzzle.vertices[v2].pos
		return p1 * 0.5 + p2 * 0.5
	elif (element_type == VERTEX_ELEMENT):
		return puzzle.vertices[id].pos
	elif (element_type == FACET_ELEMENT):
		var center = Vector2()
		for raw_face_node in raw_element['Nodes']['_arr']:
			center += puzzle.vertices[int(raw_face_node)].pos
		return center / len(raw_element['Nodes']['_arr'])
		
func __find_decorator(raw_element, xsi_type):
	if ('Decorator' in raw_element):
		var raw_decorator = raw_element['Decorator']
		if (raw_decorator['xsi:type'] == xsi_type):
			raw_decorator['__consumed'] = true
			return raw_decorator
	return null

func __add_vertex_or_edge_decorator(puzzle, raw_element, v):
	var point_decorator = __find_decorator(raw_element, "PointDecorator")
	if (point_decorator):
		puzzle.vertices[v].decorator = load('res://script/decorators/point_decorator.gd').new()
		puzzle.vertices[v].decorator.color = ColorN(point_decorator['Color'])
	var end_decorator = __find_decorator(raw_element, "EndDecorator")
	if (end_decorator):
		var end_length = float(end_decorator['Length'])
		var end_angle = deg2rad(float(end_decorator['Angle']))
		var p_end = puzzle.vertices[v].pos + Vector2(cos(end_angle), sin(end_angle)) * end_length
		var v_end = push_vertex_vec(puzzle, p_end)
		var e = push_edge_idx(puzzle, v, v_end)
		e.end_is_crossroad = true
		puzzle.vertices[v_end].decorator = load('res://script/decorators/end_decorator.gd').new()
	var text_decorator = __find_decorator(raw_element, "TextDecorator")
	if (text_decorator):
		if (text_decorator['Text'] == 'Obs'):
			var decorator = load('res://script/decorators/obstacle_decorator.gd').new()
			decorator.center = puzzle.vertices[v].pos
			decorator.size = 0.5
			decorator.radius = 1.0
			puzzle.decorators.append(decorator)
		elif (text_decorator['Text'] == '$'):
			var decorator = load('res://script/decorators/self_intersection_decorator.gd').new()
			decorator.color = ColorN(text_decorator['Color'])
			puzzle.vertices[v].decorator = decorator
		elif (text_decorator['Text'] == '[ ]'):
			var decorator = load('res://script/decorators/box_decorator.gd').new()
			decorator.color = ColorN(text_decorator['Color'])
			decorator.init_location = puzzle.vertices[v].pos
			puzzle.decorators.append(decorator)
		else:
			print('Unknown text decorator %s' % text_decorator['Text'])
	if (__find_decorator(raw_element, "StartDecorator")):
		puzzle.vertices[v].decorator = load('res://script/decorators/start_decorator.gd').new()

func __load_tetris(raw_decorator, is_hollow):
	var shapes = []
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	for raw_shape in raw_decorator['Shapes']['_arr']:
		var shape = []
		for raw_node in raw_shape['_arr']:
			var node = Vector2(float(raw_node['X']), float(raw_node['Y']))
			min_x = min(min_x, node.x)
			min_y = min(min_y, node.y)
			max_x = max(max_x, node.x)
			max_y = max(max_y, node.y)
			shape.append(node)
		shapes.append(shape)
	var center = Vector2((max_x + min_x) / 2, (max_y + min_y) / 2)
	for shape in shapes:
		for i in range(len(shape)):
			shape[i] -= center
	var decorator = load('res://script/decorators/tetris_decorator.gd').new()
	decorator.shapes = shapes
	decorator.is_hollow = is_hollow
	if (is_hollow):
		decorator.border_size = float(raw_decorator['BorderSize'])
	decorator.color = ColorN(raw_decorator['Color'])
	decorator.margin_size = float(raw_decorator['MarginSize'])
	decorator.angle = deg2rad(float(raw_decorator['Angle']))
	return decorator

func add_element(puzzle, raw_element, element_type, id=-1):
	var symmetry_decorator = __find_decorator(raw_element, "ThreeWayPuzzleDecorator")
	if (symmetry_decorator):
		puzzle.n_ways = 3
		puzzle.symmetry_type = SYMMETRY_ROTATIONAL
		puzzle.symmetry_center = __get_raw_element_center(puzzle, raw_element, element_type, id)
		puzzle.symmetry_center += Vector2(float(symmetry_decorator['DeltaX']), float(symmetry_decorator['DeltaY']))
		puzzle.solution_colors.push_back(ColorN(symmetry_decorator['SecondLineColor']))
		puzzle.solution_colors.push_back(ColorN(symmetry_decorator['ThirdLineColor']))
	if (element_type == EDGE_ELEMENT):
		var v1 = int(raw_element['Start'])
		var v2 = int(raw_element['End'])
		var p1 = puzzle.vertices[v1].pos
		var p2 = puzzle.vertices[v2].pos
		var v_mid
		if (__find_decorator(raw_element, "BrokenDecorator")):
			var p3 = p1 * 0.75 + p2 * 0.25
			var p4 = p1 * 0.25 + p2 * 0.75
			v_mid = push_vertex_vec(puzzle, p3)
			var v4 = push_vertex_vec(puzzle, p4)
			puzzle.vertices[v_mid].decorator = load('res://script/decorators/broken_decorator.gd').new()
			puzzle.vertices[v_mid].decorator.direction = (p2 - p1).normalized()
			puzzle.vertices[v4].decorator = puzzle.vertices[v_mid].decorator
			push_edge_idx(puzzle, v1, v_mid)
			push_edge_idx(puzzle, v2, v4)
		else:
			v_mid = push_vertex_vec(puzzle, p1 * 0.5 + p2 * 0.5)
			var e1 = push_edge_idx(puzzle, v1, v_mid)
			var e2 = push_edge_idx(puzzle, v2, v_mid)
			
			if (__find_decorator(raw_element, "EndDecorator")):
				e1.end_is_crossroad = true
				e2.end_is_crossroad = true
			__add_vertex_or_edge_decorator(puzzle, raw_element, v_mid)
		puzzle.edge_detector_node[[v1, v2]] = v_mid
		puzzle.edge_detector_node[[v2, v1]] = v_mid
		puzzle.edge_shared_facets[[v1, v2]] = []
		puzzle.edge_shared_facets[[v2, v1]] = []
	elif (element_type == FACET_ELEMENT):
		var facet_vertices = []
		var facet_vertex_indices = []
		var edge_tuples = []
		for raw_face_node in raw_element['Nodes']['_arr']:
			facet_vertex_indices.push_back(int(raw_face_node))
			facet_vertices.push_back(puzzle.vertices[int(raw_face_node)])
		if (len(facet_vertex_indices) > 0):
			facet_vertex_indices.push_back(facet_vertex_indices[0])
		for i in range(len(facet_vertices)):
			var edge_tuple = [facet_vertex_indices[i], facet_vertex_indices[i + 1]]
			if (not (edge_tuple in puzzle.edge_shared_facets)):
				print('Warning: facet %d missing an edge %d - %d' % [len(puzzle.facets), edge_tuple[0], edge_tuple[1]])
			else:
				puzzle.edge_shared_facets[[facet_vertex_indices[i], facet_vertex_indices[i + 1]]].append(len(puzzle.facets))
				puzzle.edge_shared_facets[[facet_vertex_indices[i + 1], facet_vertex_indices[i]]].append(len(puzzle.facets))
			edge_tuples.push_back(edge_tuple)
		var facet = Facet.new(facet_vertices)
		facet.edge_tuples = edge_tuples
		puzzle.facets.push_back(facet)
		var triangle_decorator = __find_decorator(raw_element, "TriangleDecorator")
		if (triangle_decorator):
			facet.decorator = load('res://script/decorators/triangle_decorator.gd').new()
			facet.decorator.color = ColorN(triangle_decorator['Color'])
			facet.decorator.count = int(triangle_decorator['Count'])
		var arrow_decorator = __find_decorator(raw_element, "ArrowDecorator")
		if (arrow_decorator):
			facet.decorator = load('res://script/decorators/arrow_decorator.gd').new()
			facet.decorator.color = ColorN(arrow_decorator['Color'])
			facet.decorator.count = int(arrow_decorator['Count'])
			facet.decorator.angle = deg2rad(float(arrow_decorator['Angle']))
		var star_decorator = __find_decorator(raw_element, "StarDecorator")
		if (star_decorator):
			facet.decorator = load('res://script/decorators/star_decorator.gd').new()
			facet.decorator.color = ColorN(star_decorator['Color'])
		var square_decorator = __find_decorator(raw_element, "SquareDecorator")
		if (square_decorator):
			facet.decorator = load('res://script/decorators/square_decorator.gd').new()
			facet.decorator.color = ColorN(square_decorator['Color'])
		var circle_decorator = __find_decorator(raw_element, "CircleDecorator")
		if (circle_decorator):
			facet.decorator = load('res://script/decorators/circle_decorator.gd').new()
			facet.decorator.color = ColorN(circle_decorator['Color'])
		var ring_decorator = __find_decorator(raw_element, "RingDecorator")
		if (ring_decorator):
			facet.decorator = load('res://script/decorators/ring_decorator.gd').new()
			facet.decorator.color = ColorN(ring_decorator['Color'])
		var eliminator_decorator = __find_decorator(raw_element, "EliminatorDecorator")
		if (eliminator_decorator):
			facet.decorator = load('res://script/decorators/eliminator_decorator.gd').new()
			facet.decorator.color = ColorN(eliminator_decorator['Color'])
		var tetris_decorator = __find_decorator(raw_element, "TetrisDecorator")
		if (tetris_decorator):
			facet.decorator = __load_tetris(tetris_decorator, false)
		var hollow_tetris_decorator = __find_decorator(raw_element, "HollowTetrisDecorator")
		if (hollow_tetris_decorator):
			facet.decorator = __load_tetris(hollow_tetris_decorator, true)
	if (element_type == VERTEX_ELEMENT):
		__add_vertex_or_edge_decorator(puzzle, raw_element, id)
	if ('Decorator' in raw_element):
		var raw_decorator = raw_element['Decorator']
		if (not ('__consumed' in raw_decorator)):
			print('Unsupported decorator: %s on %s' % [raw_decorator['xsi:type'], ['node', 'edge', 'facet'][element_type]])

	
func load_from_xml(file):
	var puzzle = Puzzle.new()
	puzzle.n_ways = 1
	var raw = better_xml.parse_xml_file(file)
	var raw_meta = raw['MetaData']
	puzzle.solution_colors = [ColorN(raw_meta['LineColor'])]
	puzzle.line_color = ColorN(raw_meta['ForegroundColor'])
	puzzle.background_color = ColorN(raw_meta['BackgroundColor'])
	puzzle.line_width = float(raw_meta['EdgeWidth'])
	puzzle.start_size = puzzle.line_width * 1.5
	var vertices = puzzle.vertices
	var edges = puzzle.edges
	var facets = puzzle.facets
	for raw_node in raw['Nodes']['_arr']:
		vertices.push_back(Vertex.new(float(raw_node['X']), float(raw_node['Y'])))
	for i in range(len(raw['Nodes']['_arr'])):
		var raw_node = raw['Nodes']['_arr'][i]
		add_element(puzzle, raw_node, VERTEX_ELEMENT, i)
	for raw_edge in raw['EdgesID']['_arr']:
		add_element(puzzle, raw_edge, EDGE_ELEMENT)
	for raw_face in raw['FacesID']['_arr']:
		add_element(puzzle, raw_face, FACET_ELEMENT)
	return puzzle
	
