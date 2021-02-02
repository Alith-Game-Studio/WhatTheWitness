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
	var decorator = NoDecorator.new()
	func _init(v):
		vertices = v
	
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
	
func add_element(puzzle, raw_element, element_type, id=-1):
	if (element_type == 1):
		puzzle.edges.push_back(Edge.new(
			puzzle.vertices[int(raw_element['Start'])], 
			puzzle.vertices[int(raw_element['End'])]))
	elif (element_type == 2):
		var facet_vertices = []
		for raw_face_node in raw_element['Nodes']['_arr']:
			facet_vertices.push_back(puzzle.vertices[int(raw_face_node)])
		puzzle.facets.push_back(Facet.new(facet_vertices))
	if ('Decorator' in raw_element):
		var raw_decorator = raw_element['Decorator']
		if (raw_decorator['xsi:type'] == "StartDecorator" and element_type == 0):
			puzzle.vertices[id].decorator = load('res://script/decorators/start_decorator.gd').new()
		else:
			print('Unsupported decorator: %s on %s' % [raw_decorator['xsi:type'], ['vertex', 'edge', 'facet'][id]])
		
	
	
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
	puzzle.start_size = puzzle.line_width * 2
	return puzzle
	
