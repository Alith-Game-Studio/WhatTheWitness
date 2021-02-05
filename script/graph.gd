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
	var solution_color: Color
	var line_width: float
	var start_size: float

func create_sample_puzzle():
	var puzzle = Puzzle.new()
	var vertices = {}
	var end_vertex = Vertex.new(6.2, 6.2)
	puzzle.vertices = [end_vertex]
	puzzle.edges = []
	for i in range(6):
		for j in range(6):
			vertices[Vector2(i + 1, j + 1)] = Vertex.new(i + 1, j + 1)
			puzzle.vertices.append(vertices[Vector2(i + 1, j + 1)])
	for i in range(6):
		for j in range(6):
			if (i >= 1):
				puzzle.edges.append(Edge.new(vertices[Vector2(i, j + 1)], vertices[Vector2(i + 1, j + 1)]))
			if (j >= 1):
				puzzle.edges.append(Edge.new(vertices[Vector2(i + 1, j)], vertices[Vector2(i + 1, j + 1)]))
	vertices[Vector2(1, 1)].decorator = load('res://script/decorators/start_decorator.gd').new()
	end_vertex.decorator = load('res://script/decorators/end_decorator.gd').new()
	puzzle.edges.append(Edge.new(vertices[Vector2(6, 6)], end_vertex))
	puzzle.facets = []
	puzzle.solution_color = Color(1.0, 1.0, 1.0, 1.0)
	puzzle.line_color = Color(0.7, 0.7, 0.7, 1.0)
	puzzle.background_color = Color(0.0, 0.0, 0.0, 1.0)
	puzzle.line_width = 0.1
	puzzle.start_size = 0.2
	return puzzle
	
func push_vertex_vec(puzzle, pos):
	var result = len(puzzle.vertices)
	puzzle.vertices.push_back(Vertex.new(pos.x, pos.y))
	return result

func push_edge_idx(puzzle, idx1, idx2):
	var result = len(puzzle.edges)
	puzzle.edges.push_back(Edge.new(puzzle.vertices[idx1], puzzle.vertices[idx2]))
	return result
	
func add_element(puzzle, raw_element, element_type, id=-1):
	if (element_type == 1):
		var v1 = int(raw_element['Start'])
		var v2 = int(raw_element['End'])
		var p1 = puzzle.vertices[v1].pos
		var p2 = puzzle.vertices[v2].pos
		if ('Decorator' in raw_element):
			var raw_decorator = raw_element['Decorator']
			if (raw_decorator['xsi:type'] == "BrokenDecorator"):
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
		push_edge_idx(puzzle, v3, v2)
		if ('Decorator' in raw_element):
			var raw_decorator = raw_element['Decorator']
			if (raw_decorator['xsi:type'] == "PointDecorator"):
				puzzle.vertices[v3].decorator = load('res://script/decorators/point_decorator.gd').new()
				puzzle.vertices[v3].decorator.color = ColorN(raw_decorator['Color'])
			else:
				print('Unsupported decorator: %s on edge' % raw_decorator['xsi:type'])
	elif (element_type == 2):
		var facet_vertices = []
		for raw_face_node in raw_element['Nodes']['_arr']:
			facet_vertices.push_back(puzzle.vertices[int(raw_face_node)])
		var facet = Facet.new(facet_vertices)
		puzzle.facets.push_back(facet)
		if ('Decorator' in raw_element):
			var raw_decorator = raw_element['Decorator']
			if (raw_decorator['xsi:type'] == "TriangleDecorator"):
				facet.decorator = load('res://script/decorators/triangle_decorator.gd').new()
				facet.decorator.color = ColorN(raw_decorator['Color'])
				facet.decorator.count = int(raw_decorator['Count'])
			if (raw_decorator['xsi:type'] == "StarDecorator"):
				facet.decorator = load('res://script/decorators/star_decorator.gd').new()
				facet.decorator.color = ColorN(raw_decorator['Color'])
			else:
				print('Unsupported decorator: %s on facet' % raw_decorator['xsi:type'])
	if (element_type == 0):
		if ('Decorator' in raw_element):
			var raw_decorator = raw_element['Decorator']
			if (raw_decorator['xsi:type'] == "StartDecorator"):
				puzzle.vertices[id].decorator = load('res://script/decorators/start_decorator.gd').new()
			else:
				print('Unsupported decorator: %s on vertex' % raw_decorator['xsi:type'])
	
	
	
func load_from_xml(file):
	var puzzle = Puzzle.new()
	var raw = better_xml.parse_xml_file("res://puzzles/miaoji.wit")
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
	var raw_meta = raw['MetaData']
	puzzle.solution_color = Color(1.0, 1.0, 1.0, 1.0)
	puzzle.line_color = Color(0.7, 0.7, 0.7, 1.0)
	puzzle.background_color = Color(0.0, 0.0, 0.0, 1.0)
	puzzle.line_width = float(raw_meta['EdgeWidth'])
	puzzle.start_size = puzzle.line_width * 1.5
	return puzzle
	
