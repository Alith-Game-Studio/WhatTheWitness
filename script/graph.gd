extends Node

const no_decorator = preload("res://script/decorators/no_decorator.gd")

class Vertex:
	var pos: Vector2
	var decorator = no_decorator.new()
	func _init(x, y):
		pos.x = x
		pos.y = y

class Edge:
	var start: Vertex
	var end: Vertex
	var decorator = no_decorator.new()
	func _init(v1, v2):
		start = v1
		end = v2
		
	
class Facet:
	var vertices: Array
	var decorator = no_decorator.new()
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
	
	
