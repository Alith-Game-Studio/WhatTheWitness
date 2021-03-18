extends Node

const NoDecorator = preload("res://script/decorators/no_decorator.gd")
var better_xml = preload("res://script/better_xml.gd").new()
var directory = Directory.new()

class Vertex:
	var pos: Vector2
	var decorator = NoDecorator.new()
	func _init(x, y):
		pos.x = x
		pos.y = y

class Edge:
	var start: Vertex
	var end: Vertex
	var decorator = NoDecorator.new()
	func _init(v1, v2):
		start = v1
		end = v2
		
	
class Facet:
	var vertices: Array
	var center: Vector2
	var decorator = NoDecorator.new()
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
	var symmetry_type: int # 0: rotational 1: reflective
	var symmetry_center: Vector2
	var symmetry_angle: float
	var decorators : Array
	
func push_vertex_vec(puzzle, pos):
	var result = len(puzzle.vertices)
	puzzle.vertices.push_back(Vertex.new(pos.x, pos.y))
	return result

func push_edge_idx(puzzle, idx1, idx2):
	var result = len(puzzle.edges)
	puzzle.edges.push_back(Edge.new(puzzle.vertices[idx1], puzzle.vertices[idx2]))
	return result
	
func __get_raw_element_center(puzzle, raw_element, element_type, id):
	if (element_type == 1):
		var v1 = int(raw_element['Start'])
		var v2 = int(raw_element['End'])
		var p1 = puzzle.vertices[v1].pos
		var p2 = puzzle.vertices[v2].pos
		return p1 * 0.5 + p2 * 0.5
	elif (element_type == 0):
		return puzzle.vertices[id].pos
	elif (element_type == 2):
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
	
func add_element(puzzle, raw_element, element_type, id=-1):
	var symmetry_decorator = __find_decorator(raw_element, "ThreeWayPuzzleDecorator")
	if (symmetry_decorator):
		puzzle.n_ways = 3
		puzzle.symmetry_type = 0
		puzzle.symmetry_center = __get_raw_element_center(puzzle, raw_element, element_type, id)
		puzzle.symmetry_center += Vector2(float(symmetry_decorator['DeltaX']), float(symmetry_decorator['DeltaY']))
		puzzle.solution_colors.push_back(ColorN(symmetry_decorator['SecondLineColor']))
		puzzle.solution_colors.push_back(ColorN(symmetry_decorator['ThirdLineColor']))
	if (element_type == 1):
		var v1 = int(raw_element['Start'])
		var v2 = int(raw_element['End'])
		var p1 = puzzle.vertices[v1].pos
		var p2 = puzzle.vertices[v2].pos
		if (__find_decorator(raw_element, "BrokenDecorator")):
			var p3 = p1 * 0.8 + p2 * 0.2
			var p4 = p1 * 0.2 + p2 * 0.8
			var v3 = push_vertex_vec(puzzle, p3)
			var v4 = push_vertex_vec(puzzle, p4)
			puzzle.vertices[v3].decorator = load('res://script/decorators/broken_decorator.gd').new()
			puzzle.vertices[v3].decorator.direction = (p2 - p1).normalized()
			puzzle.vertices[v4].decorator = puzzle.vertices[v3].decorator
			push_edge_idx(puzzle, v1, v3)
			push_edge_idx(puzzle, v2, v4)
			return
		var v3 = push_vertex_vec(puzzle, p1 * 0.5 + p2 * 0.5)
		push_edge_idx(puzzle, v1, v3)
		push_edge_idx(puzzle, v2, v3)
		var point_decorator = __find_decorator(raw_element, "PointDecorator")
		if (point_decorator):
			puzzle.vertices[v3].decorator = load('res://script/decorators/point_decorator.gd').new()
			puzzle.vertices[v3].decorator.color = ColorN(point_decorator['Color'])
	elif (element_type == 2):
		var facet_vertices = []
		for raw_face_node in raw_element['Nodes']['_arr']:
			facet_vertices.push_back(puzzle.vertices[int(raw_face_node)])
		var facet = Facet.new(facet_vertices)
		puzzle.facets.push_back(facet)
		var triangle_decorator = __find_decorator(raw_element, "TriangleDecorator")
		if (triangle_decorator):
			facet.decorator = load('res://script/decorators/triangle_decorator.gd').new()
			facet.decorator.color = ColorN(triangle_decorator['Color'])
			facet.decorator.count = int(triangle_decorator['Count'])
		var star_decorator = __find_decorator(raw_element, "StarDecorator")
		if (star_decorator):
			facet.decorator = load('res://script/decorators/star_decorator.gd').new()
			facet.decorator.color = ColorN(star_decorator['Color'])
	if (element_type == 0):
		if (__find_decorator(raw_element, "StartDecorator")):
			puzzle.vertices[id].decorator = load('res://script/decorators/start_decorator.gd').new()
		var end_decorator = __find_decorator(raw_element, "EndDecorator")
		if (end_decorator):
			var end_length = float(end_decorator['Length'])
			var end_angle = deg2rad(float(end_decorator['Angle']))
			var p_end = puzzle.vertices[id].pos + Vector2(cos(end_angle), sin(end_angle)) * end_length
			var v_end = push_vertex_vec(puzzle, p_end)
			push_edge_idx(puzzle, id, v_end)
			puzzle.vertices[v_end].decorator = load('res://script/decorators/end_decorator.gd').new()
		var text_decorator = __find_decorator(raw_element, "TextDecorator")
		if (text_decorator):
			if (text_decorator['Text'] == 'Obs'):
				var decorator = load('res://script/decorators/obstacle_decorator.gd').new()
				decorator.center = puzzle.vertices[id].pos
				decorator.size = 0.5
				decorator.radius = 1.0
				puzzle.decorators.append(decorator)
			else:
				print('Unknown text decorator %s' % text_decorator['Text'])
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
		add_element(puzzle, raw_node, 0, i)
	for raw_edge in raw['EdgesID']['_arr']:
		add_element(puzzle, raw_edge, 1)
	for raw_face in raw['FacesID']['_arr']:
		add_element(puzzle, raw_face, 2)
	return puzzle
	
