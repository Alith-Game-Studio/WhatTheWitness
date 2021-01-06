extends Node2D

var graph = preload("res://script/graph.gd").new()
var solution = preload("res://script/solution.gd").Solution.new()
var view_scale = 100.0

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors, [], null, null, true)


func _draw():
	var puzzle = graph.create_sample_puzzle()
	var center = Vector2(200, 200)
	var radius = 80
	var angle_from = 75
	var angle_to = 195
	var line_color = puzzle.line_color
	var line_width = puzzle.line_width * view_scale
	for vertex in puzzle.vertices:
		draw_circle(vertex.pos * view_scale, line_width / 2.0, line_color)
	for edge in puzzle.edges:
		draw_line(edge.start.pos * view_scale, edge.end.pos * view_scale, line_color, line_width, true)
	for vertex in puzzle.vertices:
		if (vertex.decorator != null):
			vertex.decorator.draw_foreground(self, vertex, 0, puzzle)
	for edge in puzzle.edges:
		if (edge.decorator != null):
			edge.decorator.draw_foreground(self, edge, 1, puzzle)
	for facet in puzzle.facets:
		if (facet.decorator != null):
			facet.decorator.draw_foreground(self, facet, 2, puzzle)
	if (solution.started):
		add_circle(solution.start_pos, 0.2, puzzle.solution_color)
	
	
func add_circle(pos, radius, color):
	draw_circle(pos * view_scale, radius * view_scale, color)
	
func add_line(pos1, pos2, width, color):
	draw_line(pos1 * view_scale, pos2 * view_scale, color, width * view_scale, true)
	
func _input(event):
	if (event is InputEventMouseButton and event.is_pressed()):
		solution.started = true
		solution.start_pos = event.position / view_scale
		self.update()
	
