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
	var v1 = Vertex.new(1, 1)
	v1.decorator = load('res://script/decorators/start_decorator.gd').new()
	var v2 = Vertex.new(1, 2)
	var v3 = Vertex.new(2, 2)
	var v4 = Vertex.new(2, 1)
	var v6 = Vertex.new(2.7, 1)
	var v7 = Vertex.new(3.2, 1.5)
	var v8 = Vertex.new(2.7, 2)
	var v9 = Vertex.new(2.8, 2.1)
	v9.decorator = load('res://script/decorators/end_decorator.gd').new()
	var e1 = Edge.new(v1, v2)
	var e2 = Edge.new(v2, v3)
	var e3 = Edge.new(v3, v4)
	var e4 = Edge.new(v4, v1)
	var e5 = Edge.new(v4, v6)
	var e6 = Edge.new(v6, v7)
	var e7 = Edge.new(v8, v7)
	var e8 = Edge.new(v3, v8)
	var e9 = Edge.new(v8, v9)
	var f1 = Facet.new([v1, v2, v3, v4])
	var puzzle = Puzzle.new()
	puzzle.vertices = [v1, v2, v3, v4, v6, v7, v8, v9]
	puzzle.edges = [e1, e2, e3, e4, e5, e6, e7, e8, e9]
	puzzle.facets = [f1]
	puzzle.solution_color = Color(1.0, 1.0, 1.0, 1.0)
	puzzle.line_color = Color(0.7, 0.7, 0.7, 1.0)
	puzzle.background_color = Color(0.0, 0.0, 0.0, 1.0)
	puzzle.line_width = 0.1
	puzzle.start_size = 0.2
	return puzzle
	
	
